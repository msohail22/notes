# Arrow's Missing Version Guard

**Issue**: 125149  
**Tags**: comp-formats, bug, starts from zero, one byte at offset 30, bounded fix

A 120-byte file names a version of the Arrow format that does not exist. ClickHouse reads it and reports a schema. It must refuse instead. This document starts from what Arrow is.

---

## Every word on this page

Read this once. Come back to it when a word stops making sense.

- **table**: Rows and columns. Like a spreadsheet.
- **column**: One field of a table, for all rows. For example every user's age.
- **buffer**: One block of raw bytes in memory. A column is stored as one or more buffers.
- **byte**: Eight bits. The smallest unit a program moves around. Written here in base 16, so `0a` means 10.
- **parse**: To read text and work out what it means. Turning the characters `"30"` into the number 30 is parsing.
- **Arrow**: A public document that fixes how a column looks in memory. It is an agreement, not a program.
- **IPC**: Inter-process communication. Here it means the envelope that carries Arrow columns from one program to another.
- **message**: One item inside that envelope. A message holds either a schema or a batch of rows.
- **schema**: The list of column names and their types. For example `age : Int32`.
- **metadata**: The small map sent beside the bytes. It says where each buffer starts and how long it is.
- **FlatBuffers**: The tool Arrow uses to write that map as bytes. Google made it. It is unrelated to Arrow itself.
- **stream and file**: Two shapes of the same envelope. A stream arrives one message at a time. A file adds a footer at the end so a reader can jump straight to any batch.
- **footer**: A small index at the end of an Arrow file. It lists where each batch sits.
- **version**: A number in each message. It names which edition of the Arrow rules the writer used.
- **submodule**: A link in one Git repository to another Git repository. ClickHouse keeps Apache Arrow's code this way, under `contrib/`.
- **contrib/**: The folder where ClickHouse keeps other people's code.
- **exception**: How ClickHouse reports an error. The query stops and the user sees a message.

---

## What Arrow is

Two programs must share a table. They have two ways to do it.

The first way is text. The writer prints the table as CSV. The reader then reads each character. It finds the commas. It converts the text `"30"` into the number 30. This work is called parsing. Parsing is slow, and the reader must do it for every value.

The second way is raw memory. The writer copies the numbers out of memory, exactly as the processor holds them. The reader puts those bytes straight into its own memory. No parsing happens. This is what Apache Arrow does.

**CSV requires the reader to parse every value; Arrow lets the reader point at the bytes without parsing.**

Arrow is fast because the reader never looks at a value. It only moves bytes. That speed is also the source of this bug.

### Who actually sends Arrow to ClickHouse

Some programs already hold their tables in the Arrow layout. Polars, pyarrow and DuckDB are built on it. For them, writing an Arrow file is not a conversion. They copy out the bytes they already have.

So the traffic goes two ways:

| Direction | How it starts | A real case |
|-----------|---------------|------------|
| ClickHouse → Arrow | `FORMAT ArrowStream` | A data scientist runs `client.query_df(...)`. The result lands in a pandas table with no parsing. |
| Arrow → ClickHouse | `file()`, `s3()`, `url()` | An hourly job writes files to S3. An analyst queries them in place with `SELECT ... FROM s3('s3://b/*.arrow', Arrow)`. |

The bug is on the second line. ClickHouse is the reader.

And there is a second reason to use Arrow, beside speed. Text loses types. In a CSV file, nobody can tell whether `007` is a number or a string, or whether an empty field is a null. Arrow carries the types in the envelope, so no guess is needed.

Arrow has two parts. The **layout** says how a column sits in memory. The **IPC format** is the envelope that moves that layout between programs. IPC means inter-process communication. ClickHouse supports the envelope under two names: `ArrowStream` for a stream of bytes, and `Arrow` for a file.

---

## How Arrow stores one column

Take a column of three rows. The second row has no value:

```
x : Nullable(Int32)
    row 0 = 10
    row 1 = NULL
    row 2 = 30
```

Arrow writes this as two blocks of raw bytes. A block is called a **buffer**.

| Buffer | Bytes | Meaning |
|--------|-------|---------|
| 0 — validity | `05` | One bit per row. `0b101`: row 0 valid, row 1 null, row 2 valid. |
| 1 — values | `0a 00 00 00  00 00 00 00  1e 00 00 00` | Three 32-bit numbers: 10, unused, 30. |

The buffers hold no labels. The byte `05` does not say "I am validity". So Arrow sends a second thing beside the body: the **metadata**. The metadata is a small map. It says this:

```
field "x" is Int32 and nullable
buffer[0] : offset 0, length 1
buffer[1] : offset 8, length 12
```

Now read the rule that causes the bug. The buffers come in a **flat list, in a fixed order**. The metadata gives each buffer an offset and a length. It does *not* say which buffer is the validity one. The reader knows that only because the Arrow specification says "validity comes first".

### Why this matters

The reader counts positions. It takes the first buffer and trusts that it is validity. It takes the second and trusts that it is values. If the reader and the writer disagree about the order, or about the count, then the reader points at the wrong bytes. It still produces a column. It produces the wrong numbers, and it reports no error.

---

## Why the format has a version number

The order and the count of the buffers are rules. Arrow has changed those rules. One change is the reason this issue exists.

A **union** column holds more than one type. One row can be an integer, and the next row can be a string. A small tag per row says which type that row uses. Arrow calls the tag buffer `type_ids`.

Up to version V4, a union carried three buffers: validity, then `type_ids`, then offsets. From version V5, Arrow removed the validity buffer. A union now carries two. The list became one buffer shorter.

**The V4-to-V5 step removed one buffer from the union layout.** A reader that assumes the wrong side of that step reads every later buffer from the wrong offset, and reports no error.

The shift produces no exception. The reader reads the tag buffer as an offsets buffer. The numbers are still numbers, and the lengths still fit. The query returns values, and every value is wrong.

So the format carries one field to stop this. Each IPC message starts with `Message.version`. That number names the rulebook. The reader reads it first, and then it knows which layout to expect.

### The rule that follows

A reader can only use a rulebook it holds. If the version field names a rulebook from the future, then the reader has no way to know the layout. It must stop and report an exception. It must not guess, because a guess gives wrong values and no warning.

Apache Arrow keeps a test file for exactly this. The file declares version **V6**, which does not exist. A correct reader refuses it. **ClickHouse accepts it.** That is issue 125149.

---

## What the bug is

Run this:

```sql
DESCRIBE url('.../data/forward-compatibility/schema_v6.arrow', ArrowStream);
```

ClickHouse answers `f0  Nullable(String)`. A `SELECT` returns zero rows and no error.

The file declares metadata version **V6**. No such version exists. Apache Arrow put this file in its test corpus for one purpose: a reader must reject it. A reader that accepts it claims to understand a format that nobody has defined yet.

---

## The versions, and the one step that matters

Arrow has published five metadata versions. Only one step between them changed a buffer count, and that step is the one above:

```
V1 ─── V2 ─── V3 ─── V4 ═════════════════ V5 ─ ─ ─ ─ V6?
                    unions carry a         unions       (undefined)
                    validity bitmap        dropped it
```

That is the whole argument. A version number the reader does not know means a buffer layout the reader does not know. The only safe answer is an exception.

---

## Where the bytes travel

Now the useful part: where does this file go inside ClickHouse?

ClickHouse used to borrow Apache Arrow's reader. It now has its own, written from scratch, under `src/Processors/Formats/Impl/ArrowIPC/`. Apache's copy still sits in the repository under `contrib/`, but this code path never calls it.

Every message passes through one function, `readNextMessage`. It runs a short list of checks and then hands the message on. Six different places in the code call that function, and a place that calls a function is a **call site**. The number matters: a check inside the function covers all six at once.

**Pipeline of checks in MessageReader::readNextMessage:**
1. framing — verify length
2. Verifier — verify shape
3. header — ensure not null
4. bodyLength — ensure ≥ 0
5. **version** — ensure ≤ MAX (this is the missing check)
6. Result: Either `Nullable(String)` (wrong) or `INCORRECT_DATA` exception (correct)

Six call sites, one chokepoint. That shape is the main hint about where the fix belongs.

| File | What it already checks | Version? |
|------|------------------------|----------|
| `ArrowIPC/MessageReader.cpp:45` | framing, metadata length, FlatBuffers shape, header union, body length sign | ❌ no |
| `ArrowIPC/SchemaConverter.cpp:943` | magic bytes, footer length, footer shape, block bounds | ❌ no |
| `contrib/arrow .../ipc/message.cc:94` | the same, plus both version bounds | ✅ yes |

The Arrow library already carries the answer. ClickHouse no longer runs that code:

```cpp
// contrib/arrow/cpp/src/arrow/ipc/message.cc:93
if (message_->version() < internal::kMinMetadataVersion)
    return Status::Invalid("Old metadata version not supported");
if (message_->version() > flatbuf::MetadataVersion::MetadataVersion_MAX)
    return Status::Invalid("Unsupported future MetadataVersion: ", ...);
```

Note that it has **two** bounds, and that `kMinMetadataVersion` is `V4`, not `V5`.

---

## The second gap, and why the lower bound is not simple

Before you write anything, two more facts. Each one changes what a correct fix looks like.

### The file format has its own version field

`readArrowFileFooter` in `SchemaConverter.cpp:943` reads `Footer`, verifies its shape, validates every block, and never reads `footer->version()`. A crafted `.arrow` file can declare V6 in its footer. Decide whether that belongs in the same change.

### ClickHouse's decoder assumes V5 for unions

Read `RecordBatchDecoder.cpp:1409`:

```cpp
/// A union has no validity buffer: a types buffer (int8),
/// and for dense unions an offsets buffer (int32).
```

True in V5. False in V4. Arrow handles both with `HasValidityBitmap(type_id, version)`. ClickHouse has no such branch, so a V4 union stream reads one buffer short and misaligns everything after it — today, with no error.

So the lower bound is a real design decision, not a copy of Arrow's constant.

---

## The change, file by file

Two files to change. Two files to add. Nothing else.

### Three decisions this diff makes

A diff cannot stay neutral, so here are the choices it takes, and why. Overrule any of them.

| Decision | Choice | Why |
|----------|--------|-----|
| upper bound | `> MetadataVersion_MAX`, plus a `static_assert` | `MAX` follows the submodule, which is what Arrow does. The `static_assert` pins it to V5, so the day someone bumps the submodule and V6 becomes real, **the build breaks** instead of the guard quietly widening to accept a layout the decoder has never seen. |
| lower bound | `< MetadataVersion_V4` | V1 to V3 predate Arrow 0.8 and nothing writes them. Rejecting below V5 instead would refuse V4 files that ClickHouse reads correctly today, which is a regression this issue did not ask for. |
| footer | same change | Same bug, same class, four lines. A file carries the number twice. |

**What this diff deliberately does not fix.** The above showed that `RecordBatchDecoder.cpp:1409` hard-codes the V5 union layout, so a V4 union is misread today. That is a *second* bug. Fixing it means either teaching the decoder the V4 union layout or rejecting V4 unions, and both are larger than this issue. File it separately and link it.

### File 1 — the fix itself (required)

**`src/Processors/Formats/Impl/ArrowIPC/MessageReader.cpp`**, in the function `readNextMessage`, which starts at line 45.

This is the one place every message goes through. Fix it here and all six call sites are covered.

```cpp
 85   flatbuffers::Verifier verifier(...);
 86   if (!flatbuf::VerifyMessageBuffer(verifier))
 87       throw ... "Corrupted Arrow IPC message metadata";
 88
 89   out.header = flatbuf::GetMessage(...);   // <-- the header exists from here down
 90
 97   if (header_type is set but header() == nullptr)
 98       throw ... "header type is set but its value is missing";
 99
100   out.body_length = out.header->bodyLength();
101   if (out.body_length < 0)
102       throw ... "Negative Arrow IPC message body length {}";
103
104   return true;
```

Your check goes **below line 89**. It cannot go above it, because line 89 is where the header becomes readable. Which line below 89 you pick is your decision.

**What you need:**
- `out.header->version()` — the version in this message, as an enum
- `flatbuf::MetadataVersion_MAX` — the newest version that exists: V5, which is 4
- `flatbuf::MetadataVersion_V4` — 3, if you decide to add a lower bound
- `ErrorCodes::INCORRECT_DATA` — the error code, already declared at line 17

**Two traps:**
- `flatbuf` is a short name set up in `FlatBuffersCommon.h:43`. Inside this folder you write `flatbuf::` and nothing longer.
- `version()` gives an enum, so the message formatter will not print it. Cast it to `Int16` first.

Do not touch `MessageReader.h`. The function signature does not change.

**The change** — Insert these lines straight after line 89:

```cpp
out.header = flatbuf::GetMessage(metadata_storage.data());

/// `Message.version` names the edition of the Arrow IPC specification the writer used, and the buffer
/// layout differs between editions: V5 removed the validity buffer from unions, so a message decoded
/// under the wrong edition's rules takes every following buffer from the wrong offset and produces
/// silently wrong values. FlatBuffers verification cannot catch this: an enum field is a plain `int16`,
/// so a value outside the enum is still a well-formed buffer. Reject an unknown edition here, before any
/// field whose meaning depends on it is read. A message with no `version` field reads as the default `V1`
/// and the same lower bound rejects it, as in the Arrow-library based reader this one replaced.
static_assert(
    flatbuf::MetadataVersion_MAX == flatbuf::MetadataVersion_V5,
    "The Arrow submodule added a metadata version. Implement its layout in RecordBatchDecoder before "
    "widening this guard.");
const auto version = out.header->version();
if (version > flatbuf::MetadataVersion_MAX)
    throw Exception(
        ErrorCodes::INCORRECT_DATA,
        "Unsupported future Arrow IPC metadata version V{}: this reader implements V4 to V5",
        static_cast<Int16>(version) + 1);
if (version < flatbuf::MetadataVersion_V4)
    throw Exception(
        ErrorCodes::INCORRECT_DATA,
        "Unsupported legacy Arrow IPC metadata version V{}: this reader implements V4 to V5",
        static_cast<Int16>(version) + 1);
```

**Three details worth understanding:**
- **Why `+ 1`.** The enum counts from zero: `V1 = 0`, so `V5 = 4`. The number in the file is 5. Adding one turns the stored number into the name a human expects, so the broken file reports `V6` and not `5`.
- **Why the cast.** `version()` gives an enum. The message formatter refuses to print an enum, so it becomes `Int16` first.
- **Why it sits above the other checks.** The checks below read `header_type` and `bodyLength`. What those fields mean depends on the edition. Refuse the unknown edition before you trust anything it says.

### File 2 — a second gap (your call)

**`src/Processors/Formats/Impl/ArrowIPC/SchemaConverter.cpp`**, in `readArrowFileFooter`, which starts at line 943.

An Arrow *file* carries a version number twice: once in each message, and once in the footer at the end. The footer one is also unchecked.

```cpp
977   if (!flatbuf::VerifyFooterBuffer(verifier))
978       throw ... "Corrupted Arrow file footer";
979   const auto * footer = flatbuf::GetFooter(...);
980
981   if (!footer->schema())             // <-- your check belongs beside this one
982       throw ... "Arrow file footer has no schema";
```

`footer->version()` exists and returns the same enum.

A file's messages still pass through File 1, so this is a second, earlier line of defence rather than the thing that stops the read.

**The change** — Insert these lines after `const auto * footer = ...`:

```cpp
const auto * footer = flatbuf::GetFooter(footer_storage.data());

/// The footer carries the metadata version too, and its block list is read under the current edition's
/// assumptions, so an unknown edition is rejected here rather than at the first message. Each message is
/// checked again in `MessageReader::readNextMessage`.
const auto version = footer->version();
if (version > flatbuf::MetadataVersion_MAX || version < flatbuf::MetadataVersion_V4)
    throw Exception(
        ErrorCodes::INCORRECT_DATA,
        "Unsupported Arrow IPC metadata version V{} in the Arrow file footer: this reader implements V4 to V5",
        static_cast<Int16>(version) + 1);

if (!footer->schema())
    throw Exception(ErrorCodes::INCORRECT_DATA, "Arrow file footer has no schema");
```

One check here instead of two, because the footer is not where a user looks for a diagnosis. The message naming both bounds is enough.

### Files 3 and 4 — the test (required)

```bash
./tests/queries/0_stateless/add-test arrow_ipc_unknown_metadata_version.sh
```

That one command makes both files: the test and its expected output. It also picks the next free number.

**The test** — You cannot ask `pyarrow` for a V6 file, because V6 does not exist. So the test writes a normal file and then changes the one byte that holds the version.

Finding that byte needs the two hops from section 06: read the root offset, then read the lookup table. Twelve lines of Python do it, and they work on any message `pyarrow` writes.

---

## Summary

- **Issue**: ClickHouse accepts Arrow IPC messages with undefined metadata versions (e.g., V6)
- **Root cause**: Missing version validation in `MessageReader::readNextMessage` and `readArrowFileFooter`
- **Fix**: Add version bounds checks in two locations before reading layout-dependent fields
- **Test**: Write a test file with V6 version and verify it's rejected with proper exception
- **Related PR**: #125134, #125149

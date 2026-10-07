#ifndef RELATIONAL_FIELD_CORE_1_0_1_H
#define RELATIONAL_FIELD_CORE_1_0_1_H
#include <stdbool.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
/* Relational Field Core 1.0.1 research API, lineage: Librarian ABI 1.14.0.
 * Handles belong to the library which created them. No cross-DLL ownership.
 * Native profile sizes: 16 or 32. No transport or execution policy in this API.
 */
typedef struct RfcCore RfcCore;
typedef struct RfcNotebookRow {
    int32_t candidate;      /* -1 = no input; otherwise 0..size-1 */
    uint32_t reaction_bits; /* binary32 bits; serialize explicitly little-endian */
    uint8_t post_sha256[32];/* local diagnostic, never wire content */
} RfcNotebookRow;
uint32_t rfc_version_major(void);
uint32_t rfc_version_minor(void);
uint32_t rfc_version_patch(void);
/* Full plain-text identity length; optional prefix copied to output. Not NUL-terminated. */
uint32_t rfc_identity(uint8_t *out, uint32_t capacity);
RfcCore *rfc_field_create(uint32_t size);
bool rfc_field_input(RfcCore *core, uint32_t size, uint32_t site);
bool rfc_reaction(RfcCore *core, uint32_t *reaction_bits);
/* Required rows on query/short buffer; rows untouched in those cases.
 * Full result published only on success. Errors: -1 invalid argument/profile,
 * -2 clone/allocation/input/measurement failure, -3 snapshot mismatch.
 * Source must not be concurrently mutated. Rows are local only.
 */
int32_t rfc_notebook(RfcCore *core, uint32_t size, RfcNotebookRow *out, uint32_t capacity);
/* Local build-bound typed logical snapshot: RFCB + schema1 header. No import API.
 * NULL queries required bytes; short output returns full required length.
 * UINT32_MAX refuses unsupported state (e.g. registered tool callbacks).
 */
uint32_t rfc_snapshot_schema(void);
uint32_t rfc_snapshot(const RfcCore *core, uint8_t *out, uint32_t capacity);
/* Legacy JSON output returns 0; JSON import returns false in this profile. */
/* Inherited ownership/step API retains its Librarian compatibility names. */
void librarian_destroy(RfcCore *core);
float librarian_step(RfcCore *core);
uint32_t librarian_version_major(void);
uint32_t librarian_version_minor(void);
uint32_t librarian_version_patch(void);
#ifdef __cplusplus
}
static_assert(sizeof(RfcNotebookRow) == 40, "RFC row ABI mismatch");
#endif
#endif

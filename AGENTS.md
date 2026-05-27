# Agent Instructions

Before making changes in this repository, read:

- `FIX_NOTES.md`
- `README.md`
- Current `git status`

Important project notes:

- Do not push directly to `develop`.
- Current fix branch is `fix/develop`.
- The quotation flow, order status flow, customer order UI, and staff order workflow were recently changed together.
- Customer quotation form intentionally does not use Flutter `Stepper`; it was removed because it caused blank/frozen content around the technical-spec step.
- Order timeline intentionally has no delivery step. Customers pick up vehicles at the company.
- If touching database/order/quotation/chat/warranty behavior, verify both customer and staff app flows.
- If touching Vietnamese UI text, check for encoding corruption such as `�`, `Ã`, `áº`, `á»`, or `ï¿½`.

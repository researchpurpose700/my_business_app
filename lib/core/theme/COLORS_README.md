# Colors Token README


## Rationale
Balanced palette chosen for shopkeeper app: reliable and calm primary blue, friendly teal secondary, and amber accent used sparingly to draw attention to discounts or important calls-to-action. Backgrounds are light to aid fast scanning for busy users.


## Where these files live
- Dart tokens: `lib/core/theme/colors.dart`
- Machine tokens: `lib/core/theme/design-tokens.json`


## How devs should use
- Import `lib/core/theme/colors.dart` and reference tokens directly: `AppColors.primary`, `AppColors.textPrimary`, etc.
- Do not use hex literals or `Colors.*` in UI widgets. If you need a color not in the list, add it to tokens first and document why.


## PR checklist for color token changes
- [ ] Add color in both `colors.dart` and `design-tokens.json`.
- [ ] Include a short usage note in the token file or README.
- [ ] Update `version` and `date` in `design-tokens.json`.
- [ ] Tag product/designer to review if the change affects core tokens.


## Next steps (Step 2)
- We will add `on*` contrast tokens (e.g., `onPrimary`) and interaction tints (hover/pressed/disabled). A contrast report will be produced and adjustments made if needed.
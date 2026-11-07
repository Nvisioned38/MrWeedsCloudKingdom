# V1 v10 art export matrix

Approval authority: `Mr_Weeds_Cloud_Kingdom_Asset_Review_v10_Standalone_Assets.xlsx` (SHA-256 `a9256d1d2802226782ab0a4ab23268c0e6eb62309c5a075052925cc03808e3c0`). The workspace archive inspected was `Game Art.zip` (SHA-256 `4a1824f098c498ffeebdfa1c90ab697f039ecc06cccdecccee29216978935739`). “Approved” records visual/design approval; it does not make a composite reference a production sprite.

## P0 Match-3 inventory

| v10 ID | Design source | Original source available | Export type | Source dimensions / alpha | Source SHA-256 | Status |
|---|---|---|---|---|---|---|
| M3-001 | Cloud Puff, blue cloud/swirl silhouette | `Game Art/Cloud_Kingdom_Match3_UI_Review_01.png` | Reference screenshot only; no complete isolated tile master | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Blocked: visual sample is cropped into a review card/cell and is not a standalone sprite. Exact crop trials retained no production-ready tile. |
| M3-002 | Mystic Bloom, green organic spiral bloom | Same review screenshot | Reference screenshot only | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Blocked: no clean isolated original; existing green spiral is explicitly an unfinished renderer fallback. |
| M3-003 | Ember Drop | Same review screenshot | Reference screenshot only | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Blocked: no clean isolated original. |
| M3-004 | Dream Crystal; tile, not currency | Same review screenshot | Reference screenshot only | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Blocked: no clean isolated original. |
| M3-005 | Golden Nugget; distinct from MW Bars | Same review screenshot | Reference screenshot only | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Blocked: no clean isolated original. |
| M3-006 | MW Crate | Same review screenshot | Reference screenshot only | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Blocked: no standalone crate export. |
| M3-007 | Reinforced MW Crate | Same review screenshot | Reference screenshot only | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Blocked: no standalone reinforced-crate export. |
| M3-008 | Cloud Cup vaporizer | Same review screenshot | Reference screenshot only | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Blocked: the shown cup includes baked lettering that is not verified as the locked BR-006 logo; do not substitute it. |
| M3-009 | Torch lighter; legacy Rocket identity retained | Same review screenshot | Reference screenshot only | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Blocked: no clean isolated original. |
| M3-010 | Prism | Same review screenshot | Reference screenshot only | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Blocked: no clean isolated original. |
| M3-011 | Cloud Bomb | Same review screenshot | Reference screenshot only | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Blocked: no clean isolated original. |
| M3-012 | Board frame | `Game Art/Cloud Cup Match-3 Kingdom Level.png` | Full level screenshot; frame is not a separate layer | 1086×1448, opaque RGB | `3a5cb794d063f5ec1b5b6d8fad45afd5e0533b2ee27a8f8599bfa4cdf25f47b7` | Blocked: static level/moves/objective examples and backdrop are baked into the composition. |
| M3-013 | Objectives panel | `Game Art/Cloud_Kingdom_Match3_UI_Review_01.png` | Composite reference; quantities are baked | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Style approved with notes; no modular panel export or completed state. |
| M3-014 | Moves counter | Same review screenshot | Composite reference; sample count is baked | 2800×1800, opaque RGB | `57ff8a18d778f0db4973dd5c8a3a57e149fe580a9f2d4be3c3e540df01a10b76` | Style approved with notes; no normal/low/zero-move component exports. |
| M3-015 | Combo/cascade effects | `Game Art/MW_img_ComboCascadeFX.png` | Composite effect study with labels and multiple scenes | 1536×1024, opaque RGB | `4b4fd9b4a17707c76410993b9001e0b4da20249db520367f06178af171535ebb` | Approved visual direction; no independent effect layers/sprite sequence. |
| — | Sticky Syrup and Fog overlays | No approved isolated source found | None | — | — | Blocked for original art; existing mechanics and labeled technical renderer cues remain. |

The preview-sheet crop trial is intentionally not shipped: sampled squares visibly include cut-off neighboring imagery and opaque review-cell framing. This fails the sprint's requirement that a crop be visually faithful and production-correct. No source pixels were altered or promoted as production sprites.

## Available character and collection art

| v10 ID | Design source | Original source / export | Dimensions / alpha | SHA-256 | Status |
|---|---|---|---|---|---|
| CH-001 + CS-001 | Mr. Weed identity and approved game-key-art poses; the selected pose has the approved OK gesture and blank white shirt | `Game Art/MW_img_CS-001b.png` → `assets/art/characters/mr_weed_portrait.png` | 1254×1254, transparent RGBA | `803803526b9a94ae40915b4ae1fce974002d9d5406e18414043166ed7e6cce69` | Integrated byte-identically; used by existing story dialogue and character catalog. Final device/visual QA remains pending. |
| CH-002 | Chef Blaze, friendly V1 Troll | `Game Art/Chef Blaze_ Cloud Kingdom Character Sheet-1.png` | 1536×1024, alpha present but opaque composite sheet | `7baf0bc31bc4b6e298a2bf028c557c4fb209d28385cc46dbea31026682ecdad6` | Approved sheet available; no clean isolated transparent portrait export yet. |
| CH-006 | The Collector, friendly V1 Troll | Approved source filenames are listed in v10 but were not located in the workspace Game Art folder | — | — | Blocked: original portrait/sheet bytes not present. Later-story villain forms/posters are excluded. |
| CO-001 | Strain card base/template | `Game Art/Mr. Weed’s Cloud Kingdom Card Framework.png` | 1448×1086, opaque composite board | `2e21f5ae9832811a2555ccffeb0e7552d6e11b3406802ec74559a1e9d52fa8ea` | Visual framework approved; individual reusable frame export is not available. |
| CO-006–009 / CO-026 | BlueBEARy Pancakes evolution stages | `Game Art/BlueBEARy Pancakes Evolution Stages.png` | 1448×1086, opaque comparison sheet | `7b61af366c217a49dee5e6da26a5e7b26c296fa39a75b29366d79a42f54f17d6` | Stage visuals approved as a comparison; stage crops are not isolated exports. Review crop bounds and collection-only placement before integration. |

Source archive artwork beyond rows traced to current v10 approvals—including villain/story images, review boards and in-review UI proofs—was not imported. `originalReceived` does not mean integrated or approved for runtime use.

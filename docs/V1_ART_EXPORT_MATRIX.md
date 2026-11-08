# V1 v10 art export matrix

Approval authority: `Mr_Weeds_Cloud_Kingdom_Asset_Review_v10_Standalone_Assets.xlsx` (SHA-256 `a9256d1d2802226782ab0a4ab23268c0e6eb62309c5a075052925cc03808e3c0`). The current standalone Match-3 handoff and owner approval are recorded below; historical source-art audits and non-Match-3 approvals remain documented separately. Visual approval, byte verification, runtime integration and device QA are distinct states.

## P0 Match-3 inventory — 2026-11-08 owner-approved handoff

Owner approved all 37 standalone Batch A + B/C exports for visual integration. The attached handoff's explicit approval supersedes stale `REVIEW REQUIRED` text in older archive README/manifest fields. Archive: `Cloud_Kingdom_All_37_Approved_Art.zip`; SHA-256 `84bc61e2155c89db11927239b4b477c8599ddc63a262bb01e757a9beb30712d7`. Each export is an independent 8-bit RGBA PNG; `python tools/verify_issue4_art.py` checks every byte hash, IHDR dimensions, and alpha-capable color type against `art_production/issue4/approved_A_manifest.csv` and `approved_BC_manifest.csv`. The separate logo-free Cloud Cup vaporizer is paired with the untouched canonical logo file `assets/art/brand/cloud_cup_logo.png`; the logo is a separate overlay. Dynamic objectives, move counts, scores, stars, labels, and reward text remain live Flutter content.

| v10 ID | Registry key | Runtime export | Dimensions / alpha | Export SHA-256 | Integration status |
|---|---|---|---|---|---|
| M3-012 | `board_frame` | `assets/art/match3/board_frame_transparent_center.png` | 1024×1024 RGBA | `09e6a36aed93711795bbace7fa20bb9c136b816a43cf511399ff1514d691c8f2` | Integrated; final visual/device QA pending |
| HUD-BOOSTER | `ui_booster_disabled` | `assets/art/match3/booster_button_disabled.png` | 256×256 RGBA | `4744a84cb4c97f316df9e8392c471be4f362996257e36ce0d508751fa001bbfa` | Integrated; final visual/device QA pending |
| HUD-BOOSTER | `ui_booster_normal` | `assets/art/match3/booster_button_normal.png` | 256×256 RGBA | `cd2ce0fb67f092515a1beaa44bc36465ea2cff9fc4e9a63be3138a6048e6afd0` | Integrated; final visual/device QA pending |
| HUD-BOOSTER | `ui_booster_pressed` | `assets/art/match3/booster_button_pressed.png` | 256×256 RGBA | `e8cab3a50db215f6e7a115d7d76f06f983dc521cccdac32676f05328ec683e1a` | Integrated; final visual/device QA pending |
| HUD-BOOSTER | `ui_booster_selected` | `assets/art/match3/booster_button_selected.png` | 256×256 RGBA | `1030982998f1d53abc18ab1e49e80d2f55aced386bb152f8318e3439a71d07af` | Integrated; final visual/device QA pending |
| M3-009 | `special_rocket_torch` | `assets/art/match3/butane_torch_lighter.png` | 256×256 RGBA | `7e5bfbc236a419deaa663a059d3f9684cfceb7524bc2fcc98100fa6f8442c84e` | Integrated; final visual/device QA pending |
| HUD-BUTTON | `ui_button_primary_blank` | `assets/art/match3/button_frame_primary_blank.png` | 800×244 RGBA | `f4f1a64a71e9cd13606b2c7502b9bbe41189bbafe1eaff2531e18de8b0f349ae` | Integrated; final visual/device QA pending |
| M3-011 | `special_cloud_bomb` | `assets/art/match3/cloud_bomb.png` | 256×256 RGBA | `eb2c27540dbd44d5c1ce67498777f82dff714c20758a3a9de7d6f3e1af93baff` | Integrated; final visual/device QA pending |
| M3-008 | `special_cloud_cup_vaporizer` | `assets/art/match3/cloud_cup_vaporizer.png` | 256×256 RGBA | `f02a1b016daaca6648d1bbd35f593b8da5727751c14731c0b2ef932548c9f669` | Integrated; final visual/device QA pending |
| M3-001 | `tile_cloud_puff` | `assets/art/match3/cloud_puff.png` | 256×256 RGBA | `2187a0f8351938a05db7e8e7f61b7b0bf2a3c1aacfcdfa97d6c6d2b4b0879239` | Integrated; final visual/device QA pending |
| M3-004 | `tile_dream_crystal` | `assets/art/match3/dream_crystal.png` | 256×256 RGBA | `3eb1489b4579a226390145bd7f7b7738aa8801e9e4c7ebc53ca75161fb457529` | Integrated; final visual/device QA pending |
| M3-003 | `tile_ember_drop` | `assets/art/match3/ember_drop.png` | 256×256 RGBA | `e65dc08c912e67e875646de9ed0c6ea2adce225d3264a8283d765cc8e94eb399` | Integrated; final visual/device QA pending |
| M3-OVERLAY-FOG | `blocker_fog` | `assets/art/match3/fog_overlay.png` | 256×256 RGBA | `77f2bef960e54dd3d9dff3b87211c6bab1b362694dc8943c6d57d8226494a5cb` | Integrated; final visual/device QA pending |
| M3-015 | `board_fx_cascade_streak` | `assets/art/match3/fx_cascade_streak.png` | 256×256 RGBA | `5d0542dbaf25142987b71d42caae7b4fc8f6aa6fdd7c33aafebf18c20e5bb584` | Integrated; final visual/device QA pending |
| M3-015 | `fx_combo_cascade` | `assets/art/match3/fx_combo_ring.png` | 256×256 RGBA | `467bdc8d55b79f57c8e4dd8d47510a381283d93124d27e37a6659191d8ca4b46` | Integrated; final visual/device QA pending |
| M3-015 | `board_fx_magic_sparkles` | `assets/art/match3/fx_magic_sparkles.png` | 256×256 RGBA | `984355951f702f225fb53b0482e5c9f656e3d57357d1406a91f7852c5e251bcc` | Integrated; final visual/device QA pending |
| M3-015 | `board_fx_smoke_1` | `assets/art/match3/fx_white_smoke_01.png` | 256×256 RGBA | `7e70ff90f60c134e37874c540328f69192d1606fb7755ef1edba2d4190248c65` | Integrated; final visual/device QA pending |
| M3-015 | `board_fx_smoke_2` | `assets/art/match3/fx_white_smoke_02.png` | 256×256 RGBA | `8103063159ce211897a0376ad13b62207a53f6295d7aea7b96f1a7a92b56e008` | Integrated; final visual/device QA pending |
| M3-015 | `board_fx_smoke_3` | `assets/art/match3/fx_white_smoke_03.png` | 256×256 RGBA | `e06c08933b787c0631dfcb29e1aef8cfdcac6666dd1dd78ff4ae70b09c7e53a1` | Integrated; final visual/device QA pending |
| M3-005 | `tile_golden_nugget` | `assets/art/match3/golden_nugget.png` | 256×256 RGBA | `24ed0014a1bfd37a6088cfedf974fcedadd60b32d0ba6e1c3d48d9fc1c87a4c6` | Integrated; final visual/device QA pending |
| M3-014 | `ui_moves_low` | `assets/art/match3/moves_counter_backing_low.png` | 256×256 RGBA | `c6caca523519d57f3e04c997d49c4f961a4000c091ada69430f0fbbc388e9339` | Integrated; final visual/device QA pending |
| M3-014 | `ui_moves_counter` | `assets/art/match3/moves_counter_backing_normal.png` | 256×256 RGBA | `8b10136b6569322cf227d5dc184833c5f2040c7938e94453343ed0bb2ec430ed` | Integrated; final visual/device QA pending |
| M3-014 | `ui_moves_zero` | `assets/art/match3/moves_counter_backing_zero.png` | 256×256 RGBA | `fff0f9ff2fed40bbbe1a0fdd1cdcadcfbd66f1e7a187cae4ddb235ff05af6733` | Integrated; final visual/device QA pending |
| M3-006 | `blocker_crate` | `assets/art/match3/mw_crate.png` | 256×256 RGBA | `ef7319d92166d91e5ec352078192a7e21525e27c64b1b6ac6a28c5ba12d7d4cb` | Integrated; final visual/device QA pending |
| M3-002 | `tile_mystic_bloom` | `assets/art/match3/mystic_bloom.png` | 256×256 RGBA | `db2e3b9da4391f7074f1acae04d4d620a0c02d21f23f6bf677aa2fc14a613e86` | Integrated; final visual/device QA pending |
| M3-013 | `ui_objective_complete` | `assets/art/match3/objective_state_complete.png` | 256×256 RGBA | `652322f03b7baa58642f1b7c5182412ff98bb96174bf3c148cfa33fe84c366f0` | Integrated; final visual/device QA pending |
| M3-013 | `ui_objective_in_progress` | `assets/art/match3/objective_state_in_progress.png` | 256×256 RGBA | `fcc74fba0b6e3024487e7e833302c53153fdfd9d59a8006716bda0f9d23474ac` | Integrated; final visual/device QA pending |
| M3-013 | `ui_objectives_panel` | `assets/art/match3/objectives_panel_backing.png` | 960×300 RGBA | `977784a015878ba5352c10e3f8d5fa33e9a3bc05e74751d5e915adfdc80870e1` | Integrated; final visual/device QA pending |
| M3-010 | `special_prism` | `assets/art/match3/prism.png` | 256×256 RGBA | `06f13c39e44e31cd3f544ac3a3c57dca42c75840a691005227d5846e48962436` | Integrated; final visual/device QA pending |
| M3-007 | `blocker_reinforced_crate` | `assets/art/match3/reinforced_mw_crate.png` | 256×256 RGBA | `2acea49ce224389395680a46cfde5455fb5ef3d27db45d3040915e874d599e29` | Integrated; final visual/device QA pending |
| HUD-SCORE | `ui_score_stars` | `assets/art/match3/score_bar_backing.png` | 960×300 RGBA | `977784a015878ba5352c10e3f8d5fa33e9a3bc05e74751d5e915adfdc80870e1` | Integrated; final visual/device QA pending |
| HUD-STAR | `ui_star_empty` | `assets/art/match3/star_empty.png` | 256×256 RGBA | `6f72d53ffb073878bd118d3c4f60eb2836d2e0c0a85d9412f88d459ef0cdf943` | Integrated; final visual/device QA pending |
| HUD-STAR | `ui_star_filled` | `assets/art/match3/star_filled.png` | 256×256 RGBA | `5d5e03e0875a64f0e532d7ed55099c182e77d0befbe878acd6782be9edb155b3` | Integrated; final visual/device QA pending |
| HUD-SCORE | `ui_star_progress_fill` | `assets/art/match3/star_progress_fill_full.png` | 920×244 RGBA | `5865618e7774fb27f3530bde7d4d3fa8e6cfab180bb487f99fae0205f9f1be07` | Integrated; final visual/device QA pending |
| HUD-SCORE | `ui_star_progress_track` | `assets/art/match3/star_progress_track_empty.png` | 920×244 RGBA | `82fdf09f056dd988e369db62f99b258410d348cd67d90ea06d0f49eacca0df38` | Integrated; final visual/device QA pending |
| M3-OVERLAY-SYRUP | `blocker_sticky_syrup` | `assets/art/match3/sticky_syrup_overlay.png` | 256×256 RGBA | `feba45585e6335764fff150a80c3045fa42c5280b5d939757fac84f471f78b57` | Integrated; final visual/device QA pending |
| HUD-VICTORY | `ui_level_complete` | `assets/art/match3/victory_reward_panel_backing.png` | 960×700 RGBA | `4c8ad7d680f021bcadc6de7608d7fc30bef74474f3aba1576404ffdaad657917` | Integrated; final visual/device QA pending |

This is artwork integration status, not a V1 release sign-off. Samsung S24 visual acceptance, complete accessibility/performance and release gates remain separate; see `docs/V1_QA_CHECKLIST.md`. `Cloud_Kingdom_Batch_D_Collection_UI_REVIEW.zip` is a review package and is excluded from the 37 approved runtime exports. No preview/contact sheet or screenshot crop is shipped.

## Available character and collection art

| v10 ID | Design source | Original source / export | Dimensions / alpha | SHA-256 | Status |
|---|---|---|---|---|---|
| CH-001 + CS-001 | Mr. Weed identity and approved game-key-art poses; the selected pose has the approved OK gesture and blank white shirt | `Game Art/MW_img_CS-001b.png` → `assets/art/characters/mr_weed_portrait.png` | 1254×1254, transparent RGBA | `803803526b9a94ae40915b4ae1fce974002d9d5406e18414043166ed7e6cce69` | Integrated byte-identically; used by existing story dialogue and character catalog. Final device/visual QA remains pending. |
| CH-002 | Chef Blaze, friendly V1 Troll | `Game Art/Chef Blaze_ Cloud Kingdom Character Sheet-1.png` | 1536×1024, alpha present but opaque composite sheet | `7baf0bc31bc4b6e298a2bf028c557c4fb209d28385cc46dbea31026682ecdad6` | Approved sheet available; no clean isolated transparent portrait export yet. |
| CH-006 | The Collector, friendly V1 Troll | Approved source filenames are listed in v10 but were not located in the workspace Game Art folder | — | — | Blocked: original portrait/sheet bytes not present. Later-story villain forms/posters are excluded. |
| CO-001 | Strain card base/template | `Game Art/Mr. Weed’s Cloud Kingdom Card Framework.png` | 1448×1086, opaque composite board | `2e21f5ae9832811a2555ccffeb0e7552d6e11b3406802ec74559a1e9d52fa8ea` | Visual framework approved; individual reusable frame export is not available. |
| CO-006–009 / CO-026 | BlueBEARy Pancakes evolution stages | `Game Art/BlueBEARy Pancakes Evolution Stages.png` | 1448×1086, opaque comparison sheet | `7b61af366c217a49dee5e6da26a5e7b26c296fa39a75b29366d79a42f54f17d6` | Stage visuals approved as a comparison; stage crops are not isolated exports. Review crop bounds and collection-only placement before integration. |

Source archive artwork beyond rows traced to current v10 approvals—including villain/story images, review boards and in-review UI proofs—was not imported. `originalReceived` does not mean integrated or approved for runtime use.

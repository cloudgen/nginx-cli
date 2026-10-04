**file**: docs/requirements/requirement-shell-cli-language.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-language`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the nginx-cli **menu language**.

**In one sentence:** Pick a language on menu row 5; the front board, the help Usage heading, and the about cache labels follow that choice. Command names stay English.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Thirteen languages, same endonyms in every UI language | menu `5` then `52` |
| Not this file | The rest of the menu tree | `requirement-shell-cli-default-interaction` |

| Includes | Excludes |
|----------|----------|
| Codes, persistence leaf, translated chrome listed in §2.3 | A full translation of every help paragraph; translating command tokens, flags, or paths |

## Under command line for normal user only

Language selection **MUST** work on Termux, Git Bash, and Windows cmd. It only changes words. It **MUST NOT** enable `setup`.

---

## 2. Core Rules (Mandatory)

### 2.1 Codes (speaker order after en, zh-Hans, zh-Hant)

| Number | Code | Endonym (unchanged in every UI language) |
|--------|------|------------------------------------------|
| 51 | en | English |
| 52 | zh-Hans | 简体中文 |
| 53 | zh-Hant | 繁體中文 |
| 54 | es | Español |
| 55 | ar | العربية |
| 56 | fr | Français |
| 57 | pt | Português |
| 58 | ru | Русский |
| 59 | de | Deutsch |
| 60 | ja | 日本語 |
| 61 | ko | 한국어 |
| 62 | nl | Nederlands |
| 63 | el | Ελληνικά |

Numbers **50** and **64–69** are reserved. They are not printed. Picking one warns and reprints the language board. It **MUST NOT** write the file. Front number **6** is not a language shortcut.

### 2.2 Load and save

1. Leaf: `${HOME}/.local/${APP_NAME}/language`. One line. Mode **0600**. Not inside the cache folder.  
2. `app_lang_load` runs **once** at the start of `app_main`, after persistence is resolved and before the zero-cli-verb split. A later load in the same process is forbidden (it would hide a pick just saved). The menu **MUST NOT** call load again.  
3. Missing, empty, or unknown first line means English and **MUST NOT** rewrite the file.  
4. `NGINX_CLI_LANG` set to a known code overrides the file for this process and **MUST NOT** by itself rewrite the file.  
5. A valid pick calls `app_lang_save` (one line, mode 0600) and returns to the front in that language. A write failure warns in the current language and does not change `APP_LANG`.

### 2.3 What follows APP_LANG (honest scope)

Translated: menu chrome, category names, leaf longs, Back / Exit / prompt / unknown / hidden messages, language saved and fail lines, help **Usage** heading, the empty-argv sentence, the about title, and the cache / persistence labels.

**Not** fully translated: the rest of the help body, and domain about lines (nginx-adm, queues). Those stay English.

Usage headings: en `Usage:`, zh-Hans and zh-Hant `用法：`, es and pt `Uso:`, ar `الاستخدام:`, fr `Utilisation :`, ru `Использование:`, de `Verwendung:`, ja `使い方:`, ko `사용법:`, nl `Gebruik:`, el `Χρήση:`.

`app_menu_text` is data only. It **MUST NOT** call the `read` builtin.

Category tokens typed on the front accept the translated shorts (for example `请求端`, `语言`, `自我管理`) as well as the English shorts.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** An unknown file line is left as the operator wrote it.  
- **Intentional:** Endonyms do not change when the UI language changes.  
- **Anti-fragile:** Env override wins for one process without clobbering the file.  
- **Over-protect:** Load once so a save survives until exit.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Store the language file in the cache folder.  
2. Rewrite an unknown language line to `en`.  
3. Call `app_lang_load` again after a menu save.  
4. Translate command tokens, flags, or paths.  
5. Claim the whole help page is translated.

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | `NGINX_CLI_LANG=ja` help contains `使い方:` |
| AC-2 | Menu pick 52 writes `zh-Hans` mode `0600` and the front shows `9. 退出` |
| AC-3 | Pick 50 does not create the language file |
| AC-4 | A first line `nope` stays `nope` and help stays `Usage:` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-storage` | Persistence directory |
| `requirement-shell-cli-default-interaction` | Menu board 5 |
| `requirement-shell-cli-interface` | Help Usage heading |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP-ID | Test | Status |
|-------|------|--------|
| **TP-CLI-28** | `tests/test_cli.sh` | have (pick 52, reserved 50, unknown line, `NGINX_CLI_LANG=ja`) |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-10-04 | Active 1.0.0 | Thirteen codes; menu chrome and selected headings |

---

**Last Updated**: 2026-10-04  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).

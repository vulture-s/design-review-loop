# Web Design Sandbox — upload limits + workarounds

> The design agent runs in a browser sandbox. These are empirical limits (no official
> spec); re-test and date your changes. Numbers below reflect claude.ai web behavior
> as observed; other web agents differ but the *shape* of the constraint is the same.

## Accepted upload formats

✅ Confirmed uploadable:
- `.md` / `.txt`
- `.json` / `.yaml` / `.yml`
- `.png` / `.jpg` / `.jpeg` / `.webp`
- `.pdf`
- `.csv`
- `.py` / `.js` / `.ts` / `.tsx` / `.html` / `.css`

❌ Rejected:
- `.svg` (vector graphics)
- `.ttf` / `.otf` / `.woff` / `.woff2` (fonts)
- native design files: `.afdesign` / `.afphoto` / `.psd` / `.sketch`
- any archive: `.zip` / `.rar` / `.7z` / `.tar.gz`

🟡 Likely rejected (untested): `.fig` / `.ai` / `.eps`

## Structural limits

- **Flat only** — no folder structure; same filename in different subfolders collides.
- **Per-file size** — on the order of tens of MB; large assets fail.
- **No disk access** — the agent cannot read a path on your machine. Files must be
  uploaded; results must be downloaded.

## Why this drives the staging discipline

Because a path and a zip are both useless to the sandbox, the outbound packing step
must produce a **flat folder of loose, web-acceptable files** for the user to drag in.
That's exactly what `stage-handover.sh` does: recurse the source, keep only accepted
formats, flatten (disambiguating collisions), and stitch the markdown into one
copy-paste bundle. The optional zip is for transfer/backup between machines — never
for the upload itself.

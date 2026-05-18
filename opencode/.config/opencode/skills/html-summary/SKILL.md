---
name: rich-html-summary
description: Generates a descriptively named HTML report in /tmp with embedded screenshots and videos.
---
# Instructions
When the task is complete:
1. **Dynamic Naming**: Create a filename based on the task (e.g., `refactor-auth-logic.html`).
2. **Location**: Save the file strictly to `/tmp/`.
3. **Media Capture**: 
    - If GUI changes occurred, take screenshots and save them to `/tmp/assets/`.
    - If tests were run, record the terminal output or UI interaction as a GIF or MP4.
4. **HTML Construction**:
    - Use a single-page HTML5 template with Tailwind CSS.
    - **Embed Media**: Use absolute paths for `<img>` and `<video>` tags pointing to the files in `/tmp/assets/`.
    - Ensure videos are set to `autoplay`, `loop`, and `muted`.
5. **Execution**: After saving, provide the user with the full path to the file.

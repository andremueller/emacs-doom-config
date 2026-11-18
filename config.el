;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;(setq doom-theme 'doom-one)
(setq doom-theme 'doom-dark+)
;; Specify both a dark and light theme, like so and Doom will choose which one
;; to load based on your system light/dark setting:
;;
;;   (setq doom-theme '(doom-one   . doom-one-light))   ; (DARK . LIGHT)
;;
;; If you want more pro-active theme switching based on OS light/dark mode, look
;; up the `auto-dark' package.

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(unless (display-graphic-p)
  (xterm-mouse-mode 1))

;; disable window splitting/pop-up style in terminal mode
(unless (display-graphic-p)
  (setq vertico-posframe-mode nil)
  (setq which-key-posframe-mode nil))

;; change through windows by ALT+arrow
(unless (display-graphic-p)
  (map! "M-<left>"  #'windmove-left
        "M-<right>" #'windmove-right
        "M-<up>"    #'windmove-up
        "M-<down>"  #'windmove-down))

;; fallback for escape sequences in terminal modes
(unless (display-graphic-p)
  (define-key input-decode-map "\e[1;3A" [M-up])
  (define-key input-decode-map "\e[1;3B" [M-down])
  (define-key input-decode-map "\e[1;3C" [M-right])
  (define-key input-decode-map "\e[1;3D" [M-left]))

;; Use the Windows clipboard in WSL terminals, without X11/Wayland tools.
(when (and (getenv "WSL_INTEROP")
           (executable-find "clip.exe")
           (executable-find "powershell.exe"))
  (defun my/wsl-copy-to-clipboard (text &optional _push)
    "Copy TEXT to the Windows clipboard, preserving Unicode."
    (let ((coding-system-for-write 'utf-16le))
      (with-temp-buffer
        (insert text)
        (unless (zerop (call-process-region (point-min) (point-max)
                                           "clip.exe" nil nil nil))
          (error "Writing to the Windows clipboard failed")))))

  (defun my/wsl-paste-from-clipboard ()
    "Read Windows clipboard text, converting CRLF to Unix newlines."
    (let ((coding-system-for-read 'utf-8-dos))
      (with-temp-buffer
        (unless (zerop
                 (call-process
                  "powershell.exe" nil t nil
                  "-NoLogo" "-NoProfile" "-NonInteractive" "-Command"
                  (concat "[Console]::OutputEncoding = "
                          "[System.Text.UTF8Encoding]::new($false); "
                          "[Console]::Write((Get-Clipboard -Raw))")))
          (error "Reading from the Windows clipboard failed: %s"
                 (buffer-string)))
        (let ((text (buffer-string)))
          (unless (string-empty-p text) text)))))

  ;; Evil's explicit "+ register uses these backends rather than kill hooks.
  (cl-defmethod gui-backend-set-selection
    (selection value &context (window-system nil))
    (when (and (eq selection 'CLIPBOARD) (stringp value))
      (my/wsl-copy-to-clipboard value)))

  (cl-defmethod gui-backend-get-selection
    (selection _target &context (window-system nil))
    (when (eq selection 'CLIPBOARD)
      (my/wsl-paste-from-clipboard)))

  (defun my/wsl-setup-clipboard ()
    "Use the Windows clipboard for terminal frames."
    (unless (display-graphic-p)
      (setq select-enable-clipboard t
            interprogram-cut-function #'gui-select-text
            interprogram-paste-function #'gui-selection-value)))

  ;; Run after Doom's tty module, which otherwise installs xclip's handlers.
  (add-hook 'tty-setup-hook #'my/wsl-setup-clipboard t)
  (my/wsl-setup-clipboard))


;; Save the session on exit and restore it automatically on startup.
(after! persp-mode
  (setq persp-auto-save-opt 1
        persp-auto-resume-time 0.5))

;; start server
(after! server
  (unless (server-running-p)
    (server-start)))

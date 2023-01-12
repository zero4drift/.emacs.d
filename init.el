;;; Grouped init.el enhanced by use-package

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.


;; general settings
;; elpa
(package-initialize)
(setq package-archives
      '(("melpa" . "http://elpa.emacs-china.org/melpa/")
	("gnu" . "http://elpa.emacs-china.org/gnu/")
	("org" . "http://elpa.emacs-china.org/org/")))

;; scheme: delete this after finishing review of SICP Exercises
(setq scheme-program-name "scheme")

;; to estimate start-up time usage
(defconst emacs-start-time (current-time))
(add-hook 'after-init-hook
	  `(lambda ()
	     (let ((elapsed (float-time (time-subtract (current-time)
						       emacs-start-time))))
	       (message "Loading %s...done (%.3fs) [after-init]"
			,load-file-name elapsed)))
	  t)

;; use-package
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)
;; end general settings


;; ui
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq-default cursor-type 'bar)

;; just do not show the original startup screen
(setq inhibit-startup-screen -1)

;; too many typing when emacs asks yes or no
(fset 'yes-or-no-p 'y-or-n-p)

;; make symbols look better
(global-prettify-symbols-mode 1)

;; subty flash the modeline instead of ringbell 'ding'
(setq ring-bell-function
      (lambda ()
        (let ((orig-fg (face-foreground 'mode-line)))
          (set-face-foreground 'mode-line
			       (face-foreground 'error))
          (run-with-idle-timer 0.3 nil
                               (lambda (fg)
				 (set-face-foreground 'mode-line
						      fg)) orig-fg))))

;; https://blog.csdn.net/xh_acmagic/article/details/78939246
(defun +my/better-font()
  (interactive)
  ;; english font
  (if (display-graphic-p)
      (progn
        (set-face-attribute 'default nil
			    ;; 11 13 17 19 23
			    :font (format "%s:pixelsize=%d" "Inconsolata"
					  18))
        ;; chinese font
        (dolist (charset '(kana han symbol cjk-misc bopomofo))
	  (set-fontset-font (frame-parameter nil 'font) charset
			    ;; 14 16 20 22 28
                            (font-spec :family "Sarasa Mono
    SC"))))))

(defun +my|init-font(frame)
  (with-selected-frame frame
    (if (display-graphic-p)
        (+my/better-font))))

(if (and (fboundp 'daemonp) (daemonp))
    (add-hook 'after-make-frame-functions #'+my|init-font)
  (+my/better-font))
;; end ui


;; functions and related keybindings
;; enhancement and binding for occur
(defun occur-dwim ()
  "Call 'occur' with a same default."
  (interactive)
  (push (if (region-active-p)
	    (buffer-substring-no-properties
	     (region-beginning)
	     (region-end))
	  (let ((sym (thing-at-point 'symbol)))
	    (when (stringp sym)
	      (regexp-quote sym))))
	regexp-history)
  (call-interactively 'occur))
(global-set-key (kbd "M-s o") 'occur-dwim)

;; bindings for recentf
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; shortcut to open init.el
(defun open-init()
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))
(global-set-key (kbd "<f4>") 'open-init)

;; functions defined for indent
(defun indent-buffer ()
  "Indent the current visited buffer."
  (interactive)
  (indent-region (point-min) (point-max)))

(defun indent-region-or-buffer ()
  "Indent a region if selected, otherwise the whole buyffer."
  (interactive)
  (save-excursion
    (if (region-active-p)
	(progn
	  (indent-region (region-beginning) (region-end))
	  (message "Indented selected region"))
      (progn
	(indent-buffer)
	(message "Indented buffer.")))))

;; shortcut to format buffer or selected region
(global-set-key (kbd "C-M-\\") 'indent-region-or-buffer)


;; files, folders, buffers and text
;; built-in dired
(setq dired-listing-switches "-alh")
(setq dired-dwim-target t)
(setq dired-recursive-copies 'always)
(setq dired-recursive-deletes 'always)
(put 'dired-find-alternate-file 'disabled nil)
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file))

;; use fundamental-mode to open large files
(defun zero4drift-check-large-file ()
  (when (> (buffer-size) 500000)
    (progn (fundamental-mode)
	   (hl-line-mode -1))))
(add-hook 'find-file-hook 'zero4drift-check-large-file)

;; when the file is modified, the related buffer will change.
(global-auto-revert-mode t)

;; do not make backup files
(setq make-backup-files nil)

;; do not auto save
(setq auto-save-default nil)

;; length of one line should not exceed 80 characters
(setq-default fill-column 80)

;; active recentf mode and set the max menu items
(recentf-mode 1)
(setq-default recentf-max-menu-items 25)

;; encoding system
(setq-default language-environment 'utf-8)

;; on-the-fly indentation
(electric-indent-mode t)

;; typed text replaces the selection
(delete-selection-mode t)
;; end functions and related keybindings


;; use packages
;; org
(use-package org
  :custom
  (org-capture-templates
   '(("j" "Journal"
      entry (file+datetree "~/.org/journal.org")
      "* %U - %^{heading} %^g\n %?\n"))))
;; org-pomodoro
(use-package org-pomodoro
  :after org
  :custom
  (org-pomodoro-format "%s"))
;; end org

;; deft
(use-package deft
  :bind
  (("C-c n" . deft) ("C-x C-g" . deft-find-file))
  :custom
  (deft-default-extension "org")
  (deft-directory "~/.org/deft/")
  (deft-recursive t)
  (deft-text-mode 'org-mode)
  (deft-use-filter-string-for-filename nil)
  (deft-org-mode-title-prefix nil)
  (deft-use-filename-as-title t))

;; iedit
(use-package iedit
  :bind
  (("C-;" . iedit-mode)))

;; expand-region
(use-package expand-region
  :bind
  (("C-=". er/expand-region)))

;; company
(use-package company
  :custom
  (company-idle-delay 0.1)
  (company-show-numbers t)
  (company-tooltip-align-annotations t)
  (company-minimum-prefix-length 3)
  :hook
  (after-init . global-company-mode)
  :bind
  (:map company-active-map
	("M-n" . nil)
	("M-p" . nil)
	("C-n" . #'company-select-next)
	("C-p" . #'company-select-previous)))

;; begins ccls
(use-package lsp-mode
  :commands lsp
  :config
  (set-face-attribute
   'lsp-face-highlight-read nil
   :underline (face-foreground 'warning))
  (set-face-attribute
   'lsp-face-highlight-write nil
   :underline (face-foreground 'error))
  (set-face-attribute
   'lsp-face-highlight-textual nil
   :underline (face-foreground 'success))
  :custom
  (lsp-prefer-flymake nil))

(use-package lsp-ui
  :commands lsp-ui-mode
  :after (evil)
  :hook
  (lsp-mode . lsp-ui-mode)
  :bind
  (:map evil-normal-state-map
	("M-." . lsp-ui-peek-find-definitions)
	("C-p" . lsp-ui-peek-jump-forward)
	("C-t" . lsp-ui-peek-jump-backward))
  (:map lsp-ui-mode-map
	([remap xref-pop-marker-stack]
	 . lsp-ui-find-references)))

(use-package company-lsp
  :commands company-lsp
  :defer t
  :custom
  (company-quickhelp-delay 1)
  (company-lsp-enable-snippet t)
  (company-lsp-async t)
  (company-lsp-cache-candidates nil)
  (company-lsp-enable-recompletion t)
  :config
  (push 'company-lsp company-backends))

(use-package ccls
  :config
  (defun ccls/callee () (interactive)
	 (lsp-ui-peek-find-custom "$ccls/call" '(:callee t)))
  (defun ccls/caller () (interactive)
	 (lsp-ui-peek-find-custom "$ccls/call"))
  (defun ccls/vars (kind)
    (lsp-ui-peek-find-custom "$ccls/vars" `(:kind ,kind)))
  (defun ccls/base (levels)
    (lsp-ui-peek-find-custom "$ccls/inheritance" `(:levels ,levels)))
  (defun ccls/derived (levels)
    (lsp-ui-peek-find-custom "$ccls/inheritance" `(:levels ,levels :derived t)))
  (defun ccls/member (kind) (interactive)
	 (lsp-ui-peek-find-custom "$ccls/member" `(:kind ,kind)))

  ;; References w/ Role::Role
  (defun ccls/references-read () (interactive)
	 (lsp-ui-peek-find-custom
	  "textDocument/references"
	  (plist-put
	   (lsp--text-document-position-params) :role 8)))

  ;; References w/ Role::Write
  (defun ccls/references-write ()
    (interactive)
    (lsp-ui-peek-find-custom
     "textDocument/references"
     (plist-put
      (lsp--text-document-position-params) :role 16)))

  ;; References w/ Role::Dynamic bit (macro expansions)
  (defun ccls/references-macro () (interactive)
	 (lsp-ui-peek-find-custom
	  "textDocument/references"
	  (plist-put
	   (lsp--text-document-position-params) :role 64)))

  ;; References w/o Role::Call bit (e.g. where functions are taken addresses)
  (defun ccls/references-not-call () (interactive)
	 (lsp-ui-peek-find-custom
	  "textDocument/references"
	  (plist-put
	   (lsp--text-document-position-params) :excludeRole 32)))
  ;; ccls/vars ccls/base ccls/derived ccls/members have a parameter while others are interactive.
  ;; (ccls/base 1) direct bases
  ;; (ccls/derived 1) direct derived
  ;; (ccls/member 2) => 2 (Type) => nested classes / types in a namespace
  ;; (ccls/member 3) => 3 (Func) => member functions / functions in a namespace
  ;; (ccls/member 0) => member variables / variables in a namespace
  ;; (ccls/vars 1) => field
  ;; (ccls/vars 2) => local variable
  ;; (ccls/vars 3) => field or local variable. 3 = 1 | 2
  ;; (ccls/vars 4) => parameter
  :custom
  (ccls-executable "/opt/local/bin/ccls-clang-8.0")
  (ccls-args '("--log-file=/tmp/ccls.log"))
  (ccls-initialization-options
   '(:clang (:extraArgs
	     ["-isystem/Library/Developer/CommandLineTools/usr/include/c++/v1"
	      "-isystem/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"
	      "-isystem/opt/local/include"])))
  :hook ((c-mode c++-mode) .
	 (lambda () (require 'ccls) (lsp))))
;; ends ccls

;; yasnippet
(use-package yasnippet-snippets)

(use-package yasnippet
  :hook
  (after-init . yas-global-mode))

;; flycheck
(use-package flycheck
  :custom
  (flycheck-disabled-checkers '(c/c++-clang c/c++-cppcheck
					    c/c++-gcc))
  :hook
  (prog-mode . flycheck-mode))

;; ledger-mode
(use-package ledger-mode
  :init
  (defun open-ledger()
    (interactive)
    (find-file "~/.accounting/now.ledger"))
  :bind (([f3] . open-ledger)))

;; magit
(use-package magit
  :bind
  (("C-x g" . magit-status)))

;; smartparens
(use-package smartparens-config
  :ensure smartparens
  :hook
  (prog-mode . turn-on-smartparens-strict-mode)
  (after-init . show-smartparens-global-mode))

;; hydra
(use-package hydra
   :defer t)

(defhydra hydra-smartparens (global-map "M-p s" :hint nil)
 "
 Moving^^^^                       Slurp & Barf^^   Wrapping^^            Sexp juggling^^^^               Destructive
------------------------------------------------------------------------------------------------------------------------
 [_a_] beginning  [_n_] down      [_h_] bw slurp   [_R_]   rewrap        [_S_] split   [_t_] transpose   [_c_] change inner  [_w_] copy
 [_e_] end        [_N_] bw down   [_H_] bw barf    [_u_]   unwrap        [_s_] splice  [_A_] absorb      [_C_] change outer
 [_f_] forward    [_p_] up        [_l_] slurp      [_U_]   bw unwrap     [_r_] raise   [_E_] emit        [_k_] kill          [_g_] quit
 [_b_] backward   [_P_] bw up     [_L_] barf       [_(__{__[_] wrap (){}[]   [_j_] join    [_o_] convolute   [_K_] bw kill       [_q_] quit"
 ;; Moving
 ("a" sp-beginning-of-sexp)
 ("e" sp-end-of-sexp)
 ("f" sp-forward-sexp)
 ("b" sp-backward-sexp)
 ("n" sp-down-sexp)
 ("N" sp-backward-down-sexp)
 ("p" sp-up-sexp)
 ("P" sp-backward-up-sexp)
 
 ;; Slurping & barfing
 ("h" sp-backward-slurp-sexp)
 ("H" sp-backward-barf-sexp)
 ("l" sp-forward-slurp-sexp)
 ("L" sp-forward-barf-sexp)
 
 ;; Wrapping
 ("R" sp-rewrap-sexp)
 ("u" sp-unwrap-sexp)
 ("U" sp-backward-unwrap-sexp)
 ("(" sp-wrap-round)
 ("{" sp-wrap-curly)
 ("[" sp-wrap-square)
 
 ;; Sexp juggling
 ("S" sp-split-sexp)
 ("s" sp-splice-sexp)
 ("r" sp-raise-sexp)
 ("j" sp-join-sexp)
 ("t" sp-transpose-sexp)
 ("A" sp-absorb-sexp)
 ("E" sp-emit-sexp)
 ("o" sp-convolute-sexp)
 
 ;; Destructive editing
 ("c" sp-change-inner :exit t)
 ("C" sp-change-enclosing :exit t)
 ("k" sp-kill-sexp)
 ("K" sp-backward-kill-sexp)
 ("w" sp-copy-sexp)

 ("q" nil)
 ("g" nil))

;; enhanced and human-friendly help functions and interfaces
(use-package helpful
  :bind
  (("C-h k" . helpful-key)
   ("C-c C-d" . helpful-at-point)
   ("C-h F" . helpful-function)
   ("C-h C" . helpful-command)
   :map helpful-mode-map
   ([remap evil-record-macro] . quit-window)))

;; counsel
(use-package counsel
  :hook
  (after-init . ivy-mode)
  (after-init . counsel-mode)
  :bind
  (("\C-s" . swiper)
   ("C-c C-r" . ivy-resume)
   :map minibuffer-local-map
   ("C-r" . counsel-minibuffer-history))
  :custom
  (ivy-use-virtual-buffers t)
  (enable-recursive-minibuffers t)
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable))

;; solarized-theme
(use-package solarized-theme
  :config
  (load-theme 'solarized-dark t))

;; doom-modeline
;; manual run all-the-icons-install-fonts
(use-package doom-modeline
  :after solarized-theme
  :defer t
  :config
  (set-face-attribute 'mode-line nil
		      :underline
		      (face-background 'highlight))
  (set-face-attribute 'mode-line-inactive nil
		      :underline nil
		      :background
		      (face-background 'highlight))
  :custom
  (doom-modeline-buffer-file-name-style 'truncate-upto-root)
  (doom-modeline-continuous-word-count-modes '(markdown-mode
					       org-mode))
  :hook (after-init . doom-modeline-mode))

;; ace-window
(use-package ace-window
  :defer t
  :custom
  (aw-background nil)
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (aw-background nil)
  (aw-dispatch-always t)
  (aw-minibuffer-flag t)
  :bind (("C-x o" . ace-window)))

;; treemacs
(use-package treemacs
  :defer t
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
	  treemacs-directory-name-transformer    #'identity
          treemacs-display-in-side-window        t
	  treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
	  treemacs-file-extension-regex          treemacs-last-period-regex-value
          treemacs-file-follow-delay             0.2
	  treemacs-file-name-transformer         #'identity
          treemacs-follow-after-init             t
	  treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         t
	  treemacs-max-git-entries               5000
	  treemacs-missing-project-action        'ask
          treemacs-no-png-images                 nil
	  treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
	  treemacs-position                      'left
	  treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
	  treemacs-recenter-after-project-jump   'always
	  treemacs-recenter-after-project-expand 'on-distance
	  treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-desc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-width                         35)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;; (treemacs-resize-icons 44)
    
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
	([f2] . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after treemacs evil
  :ensure t)

(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package treemacs-magit
  :after treemacs magit
  :ensure t)

;; which-key
(use-package which-key
  :hook
  (after-init . which-key-mode)
  :custom
  (which-key-show-early-on-C-h t)
  (which-key-idle-delay 10000)
  (which-key-idle-secondary-delay 0.05)
  (which-key-sort-order 'which-key-local-then-key-order)
  :config
  (which-key-setup-side-window-right-bottom))

;; evil-nerd-commenter
(use-package evil-nerd-commenter
  :ensure t)

;; begin evil conf
;; evil-leader
(use-package evil-leader
  :after evil-nerd-commenter
  :hook
  (after-init . global-evil-leader-mode)
  :config
  (evil-leader/set-key
   "ff" 'find-file
   "bb" 'switch-to-buffer
   ":"  'counsel-M-x
   ;; evil-nerd-commenter
   "ci" 'evilnc-comment-or-uncomment-lines
   "cl" 'evilnc-quick-comment-or-uncomment-to-the-line
   "cc" 'evilnc-copy-and-comment-lines
   "cp" 'evilnc-comment-or-uncomment-paragraphs
   "cr" 'comment-or-uncomment-region
   "cv" 'evilnc-toggle-invert-comment-line-by-line
   "."  'evilnc-copy-and-comment-operator
   "\\" 'evilnc-comment-operator ; if you prefer backslash key
   ))

;; evil-surround
(use-package evil-surround
  :hook
  (evil-mode . turn-on-evil-surround-mode)
  (c++-mode .
	    (lambda ()
	      (push '(?< . ("<" . ">"))
		    evil-surround-pairs-alist)))
  (emacs-lisp-mode .
		   (lambda ()
                     (push '(?` . ("`" . "'"))
			   evil-surround-pairs-alist))))

;; evil-mode
(use-package evil
  :hook
  (global-evil-leader-mode . evil-mode))
;; end evil confs

;; built-in display-line-mode
(use-package display-line-numbers
  :custom
  (display-line-numbers-width 2)
  (display-line-numbers-grow-only t)
  :init
  (set-face-background 'line-number-current-line
		       (face-foreground 'success))
  :hook
  ((prog-mode text-mode) . #'display-line-numbers-mode))

;; blog
(use-package easy-hugo
  :custom
  (easy-hugo-basedir "~/Documents/github/blog")
  (easy-hugo-url "https://zero4drift.github.io")
  (easy-hugo-default-ext ".org")
  (easy-hugo-default-picture-directory "~/Pictures"))
;; end blog
;; end use-packages


(provide 'init)
;;; init.el ends here

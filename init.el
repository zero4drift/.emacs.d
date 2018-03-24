;; Grouped init.el enhanced by use-package

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;; (package-initialize)


;; elpa
(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (setq package-archives
	'(("melpa" . "http://elpa.emacs-china.org/melpa/")
	  ("gnu" . "http://elpa.emacs-china.org/gnu/")
	  ("org" . "http://elpa.emacs-china.org/org/"))))

(eval-when-compile
  (require 'use-package))

;; custom file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

(when (file-exists-p custom-file)
  (load custom-file))


;; 设置垃圾回收，在Windows下，emacs25版本会频繁出发垃圾回收，所以需要设置
(when (eq system-type 'windows-nt)
  (setq gc-cons-threshold (* 512 1024 1024))
  (setq gc-cons-percentage 0.5)
  (run-with-idle-timer 5 t #'garbage-collect)
  ;; 显示垃圾回收信息，这个可以作为调试用
  ;; (setq garbage-collection-messages t)
  )


;; ui
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq-default cursor-type 'bar)
(global-linum-mode t)
(global-hl-line-mode t)

;; just do not show the original startup screen
(setq inhibit-startup-screen -1)

;; ignore the ring bell
(setq ring-bell-function 'ignore)

;; too many typing when emacs asks yes or no
(fset 'yes-or-no-p 'y-or-n-p)

;; make symbols look better
(global-prettify-symbols-mode 1)

;; Auto generated by cnfonts
;; <https://github.com/tumashu/cnfonts>
(set-face-attribute
 'default nil
 :font (font-spec :name "Source Code Pro"
                  :weight 'normal
                  :slant 'normal
                  :size 10.0))
(dolist (charset '(kana han symbol cjk-misc bopomofo))
  (set-fontset-font
   (frame-parameter nil 'font)
   charset
   (font-spec :name "Source Han Sans"
              :weight 'normal
              :slant 'normal
              :size 12.0)))

;; modeline
(defun mode-line-fill (face reserve)
  "Return empty space using FACE and leaving RESERVE space on the right."
  (unless reserve
    (setq reserve 20))
  (when (and window-system (eq 'right (get-scroll-bar-mode)))
    (setq reserve (- reserve 3)))
  (propertize " "
	      'display `((space :align-to
				(- (+ right right-fringe right-margin) ,reserve)))
	      'face face))

(defun buffer-encoding-abbrev ()
  "The line ending convention used in the buffer."
  (let ((buf-coding (format "%s" buffer-file-coding-system)))
    (if (string-match "\\(dos\\|unix\\|mac\\)" buf-coding)
	(match-string 1 buf-coding)
      buf-coding)))

(setq-default my-flycheck-mode-line
	      '(:eval
		(pcase flycheck-last-status-change
		  (`not-checked nil)
		  (`no-checker (propertize " -" 'face 'warning))
		  (`running (propertize " ✷" 'face 'success))
		  (`errored (propertize " !" 'face 'error))
		  (`finished
		   (let* ((error-counts (flycheck-count-errors flycheck-current-errors))
			  (no-errors (cdr (assq 'error error-counts)))
			  (no-warnings (cdr (assq 'warning error-counts)))
			  (face (cond (no-errors 'error)
				      (no-warnings 'warning)
				      (t 'success))))
		     (propertize (format "[%s/%s]" (or no-errors 0) (or no-warnings 0))
				 'face face)))
		  (`interrupted " -")
		  (`suspicious '(propertize " ?" 'face 'warning)))))

(setq-default mode-line-format
	      (list
	       "%1 "
	       ;; the buffer name; the file name as a tool tip
	       '(:eval (propertize "%b " 'face 'font-lock-keyword-face
				   'help-echo (buffer-file-name)))
	       
	       " [" ;; insert vs overwrite mode, input-method in a tooltip
	       '(:eval (propertize (if overwrite-mode "Ovr" "Ins")
				   'face 'font-lock-preprocessor-face
				   'help-echo (concat "Buffer is in "
						      (if overwrite-mode
							  "overwrite"
							"insert") " mode")))

	       ;; was this buffer modified since the last save?
	       '(:eval (when (buffer-modified-p)
			 (concat ","  (propertize "Mod"
						  'face 'font-lock-warning-face
						  'help-echo "Buffer has been modified"))))

	       ;; is this buffer read-only?
	       '(:eval (when buffer-read-only
			 (concat ","  (propertize "RO"
						  'face 'font-lock-type-face
						  'help-echo "Buffer is read-only"))))
	       "] "

	       ;; relative position, size of file
	       "["
	       (propertize "%p" 'face 'font-lock-constant-face) ;; % above top
	       "/"
	       (propertize "%I" 'face 'font-lock-constant-face) ;; size
	       "] "

	       ;; the current major mode for the buffer.
	       '(:eval (propertize "%m" 'face 'font-lock-string-face
				   'help-echo buffer-file-coding-system))

	       "%1 "
	       my-flycheck-mode-line
	       "%1 "

	       ;; minor modes but I feel that's too many
	       ;; minor-mode-alist
	       
	       " "
	       ;; git info
	       `(vc-mode vc-mode)

	       " "
	       
	       ;; global-mode-string goes in mode-line-misc-info
	       mode-line-misc-info

	       (mode-line-fill 'mode-line 20)

	       ;; line and column
	       "(" ;; '%02' to set to 2 chars at least; prevents flickering
	       (propertize "%02l" 'face 'font-lock-type-face) ","
	       (propertize "%02c" 'face 'font-lock-type-face)
	       ") "

	       '(:eval (buffer-encoding-abbrev))
	       mode-line-end-spaces " "
	       ;; add the time, with the date and the emacs uptime in the tooltip
	       '(:eval (propertize (format-time-string "%H:%M")
				   'help-echo
				   (concat (format-time-string "%c; ")
					   (emacs-uptime "Uptime:%hh"))))))


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

;; bindings for dired
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file))

;; shortcut to open init.el
(defun open-init()
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))
(global-set-key (kbd "<f2>") 'open-init)

;; shortcut to find function, variable
(global-set-key (kbd "C-h C-f") 'find-function)
(global-set-key (kbd "C-h C-v") 'find-variable)
(global-set-key (kbd "C-h C-k") 'find-function-on-key)

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

;; hippie-expand enhanced
(setq hippie-expand-try-functions-list '(try-expand-dabbrev
					 try-expand-dabbrev-all-buffers
					 try-expand-dabbrev-from-kill
					 try-complete-file-name-partially
					 try-complete-file-name
					 try-expand-all-abbrevs
					 try-expand-list
					 try-expand-line
					 try-complete-lisp-symbol-partially
					 try-complete-lisp-symbol))

;; shortcut to auto complete when company not triggered
(global-set-key (kbd "C-c /") 'hippie-expand)


;; files, folders, buffers and text
;; dired
(setq-default dired-dwim-target t)
(setq-default dired-recursive-copies 'always)
(setq-default dired-recursive-deletes 'always)
(put 'dired-find-alternate-file 'disabled nil)

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

;; show parens enhanced
(add-hook 'emacs-lisp-mode-hook 'show-paren-mode)
(define-advice show-paren-function (:around (fn) fix-show-paren-function)
  "Hightlight enclosing parens"
  (cond ((looking-at-p "\\s(") (funcall fn))
	(t (save-excursion
	     (ignore-errors (backward-up-list))
	     (funcall fn)))))

;; on-the-fly indentation
(electric-indent-mode t)

;; typed text replaces the selection
(delete-selection-mode t)

;; associate e-lisp-mode with abbrev-mode, define an abbrev
(add-hook 'emacs-lisp-mode-hook (lambda () (abbrev-mode t)))
(define-abbrev-table 'global-abbrev-table '(
					    ;; signature
					    ("z4d" "zero4drift")
					    ))


;; org
(use-package org
  :ensure org-plus-contrib
  :mode ("\\.org\\'" . org-mode)
  :custom
  ;; allow e-lisp code evaluated in org files
  (org-babel-do-load-languages
   'org-babel-load-languages '((emacs-lisp . t)
			       (ledger . t)))
  (org-src-fontify-natively t)
  ;; move org clock info into drawer
  ;;(org-clock-into-drawer t)
  ;; move org log info into drawer
  (org-log-into-drawer t)
  (org-log-done 'time)
  (org-log-state-notes-insert-after-drawers nil)
  (org-tag-alist (quote (("@errand" . ?e)
			 ("@office" . ?o)
			 ("@home" . ?h)
			 ("@school" . ?s)
			 (:newline)
			 ("WAITING" . ?w)
			 ("HOLD" . ?H)
			 ("CANCELLED" . ?c))))
  (org-fast-tag-selection-single-key nil)
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil)
  (org-refile-allow-creating-parent-nodes 'cofirm)
  (org-refile-targets '(("next.org" :level . 0)
			("someday.org" :level . 0)
			("projects.org" :maxlevel . 1)))
  (org-return-follows-link t)
  (org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
     (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)")))
  :bind
  (("C-c a" . org-agenda)
   ("C-c c" . org-capture)
   ("C-c l" . org-store-link)
   ("C-c b" . org-iswitchb)
   :map org-mode-map
   ("M-n" . outline-next-visible-heading)
   ("M-p" . outline-previous-visible-heading))
  :config
  (add-to-list 'org-structure-template-alist
	       '("el" "#+BEGIN_SRCemacs-lisp :tangle yes?\n\n#+END_SRC")))

(require 'find-lisp)
(setq zero4drift/org-agenda-directory "~/.org/gtd/")
(setq org-agenda-files (find-lisp-find-files zero4drift/org-agenda-directory "\.org$"))

;; Stage 1: Collecting
(setq org-capture-templates `(("i" "inbox"
			       entry (file "~/.org/gtd/inbox.org")
			       "* TODO %?")
			      ("e" "email"
			       entry (file+headline "~/.org/gtd/projects.org" "Emails")
			       "* TODO [#A] Reply:%a :@home:@school:" :immediate-finisht)
			      ("w" "Weekly Review"
			       entry (file+olp+datetree "~/.org/gtd/reviews.org")
			       (file "~/.org/gtd/templates/weekly_review.org"))
			      ("s" "Snippet"
			       entry (file "~/.org/deft/capture.org")
			       "* Snippet %<%Y-%m-%d %H:%M>\n%?")))

;; Stage 2: Processing
(require 'org-agenda)
(setq zero4drift/org-agenda-inbox-view
      `("i" "Inbox" todo ""
	((org-agenda-files '("~/.org/gtd/inbox.org")))))
(setq zero4drift/org-agenda-someday-view
      `("s" "Someday" todo ""
	((org-agenda-files '("~/.org/gtd/someday.org")))))

(defun zero4drift/org-rename-item ()
  (interactive)
  (save-excursion
    (when (org-at-heading-p)
      (let* ((hl-text (nth 4 (org-heading-components)))
	     (new-header (read-string "New Text: " nil nil hl-text)))
	(unless (or (null hl-text)
		    (org-string-match-p "^[ \t]*:[^:]+:$" hl-text))
	  (beginning-of-line)
	  (search-forward hl-text (point-at-eol))
	  (replace-string
	   hl-text
	   new-header
	   nil (- (point) (length hl-text)) (point)))))))

(defun zero4drift/org-agenda-process-inbox-item (&optional goto rfloc no-update)
  (interactive "P")
  (org-with-wide-buffer
   (org-agenda-set-tags)
   (org-agenda-priority)
   (org-agenda-set-effort)
   (org-agenda-refile nil nil t)
   ;; (org-mark-ring-push)
   ;; (org-refile-goto-last-stored)
   ;; (zero4drift/org-rename-item)
   ;; (org-mark-ring-goto)
   (org-agenda-redo)))

(defun zero4drift/org-inbox-capture ()
  "Capture a task in agenda mode."
  (interactive)
  (org-capture nil "i"))

(define-key org-agenda-mode-map "i" 'org-agenda-clock-in)
(define-key org-agenda-mode-map "r" 'zero4drift/org-agenda-process-inbox-item)
(define-key org-agenda-mode-map "R" 'org-agenda-refile)
(define-key org-agenda-mode-map "c" 'zero4drift/org-inbox-capture)

(defvar zero4drift/new-project-template
  "
    *Project Purpose/Principles*:

    *Project Outcome*:
    "
  "Project template, inserted when a new project is created")

(defvar zero4drift/is-new-project nil
  "Boolean indicating whether it's during the creation of a new project")

(defun zero4drift/refile-new-child-advice (orig-fun parent-target child)
  (let ((res (funcall orig-fun parent-target child)))
    (save-excursion
      (find-file (nth 1 parent-target))
      (goto-char (org-find-exact-headline-in-buffer child))
      (org-add-note)
      )
    res))

(advice-add 'org-refile-new-child :around #'zero4drift/refile-new-child-advice)

(defun zero4drift/set-todo-state-next ()
  "Visit each parent task and change NEXT states to TODO"
  (org-todo "NEXT"))

(add-hook 'org-clock-in-hook 'zero4drift/set-todo-state-next 'append)

;; Stage 3: Reviewing
(setq org-agenda-block-separator nil)
(setq org-agenda-start-with-log-mode t)
(setq zero4drift/org-agenda-todo-view
      `(" " "Agenda"
	((agenda ""
		 ((org-agenda-span 'day)
		  (org-deadline-warning-days 365)))
	 (todo "TODO"
	       ((org-agenda-overriding-header "To Refile")
		(org-agenda-files '("~/.org/gtd/inbox.org"))))
	 (todo "NEXT"
	       ((org-agenda-overriding-header "In Progress")
		(org-agenda-files '("~/.org/gtd/someday.org"
				    "~/.org/gtd/projects.org"
				    "~/.org/gtd/next.org"))
		;; (org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled))
		))
	 (todo "TODO"
	       ((org-agenda-overriding-header "Todo")
		(org-agenda-files '("~/.org/gtd/projects.org"
				    "~/.org/gtd/next.org"))
		(org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled))))
	 nil)))

(defun zero4drift/org-agenda-skip-all-siblings-but-first ()
  "Skip all but the first non-done entry."
  (let (should-skip-entry)
    (unless (or (org-current-is-todo)
		(not (org-get-scheduled-time (point))))
      (setq should-skip-entry t))
    (save-excursion
      (while (and (not should-skip-entry) (org-goto-sibling t))
	(when (org-current-is-todo)
	  (setq should-skip-entry t))))
    (when should-skip-entry
      (or (outline-next-heading)
	  (goto-char (point-max))))))

(defun org-current-is-todo ()
  (string= "TODO" (org-get-todo-state)))

(defun zero4drift/switch-to-agenda ()
  (interactive)
  (org-agenda nil " ")
  (delete-other-windows))

(bind-key "<f1>" 'zero4drift/switch-to-agenda)

;; Column View
(setq org-columns-default-format "%40ITEM(Task) %Effort(EE){:}
  %CLOCKSUM(Time Spent) %SCHEDULED(Scheduled)
  %DEADLINE(Deadline)")

(setq org-agenda-custom-commands
      `(,zero4drift/org-agenda-inbox-view
	,zero4drift/org-agenda-someday-view
	,zero4drift/org-agenda-todo-view))

;; Stage 4: Doing
;; org-pomodoro
(use-package org-pomodoro
  :ensure t
  :bind
  (:map org-agenda-mode-map
	(("I" . org-pomodoro)))
  :custom
  (org-pomodoro-format "%s"))

;; deft
(use-package deft
  :ensure t
  :bind
  (("C-c n" . deft))
  :custom
  (deft-default-extension "org")
  (deft-directory "~/.org/deft/")
  (deft-use-filename-as-title t))

;; iedit
(use-package iedit
  :ensure t
  :bind
  (("C-;" . iedit-mode)))

;; expand-region
(use-package expand-region
  :ensure t
  :bind
  (("C-=". er/expand-region)))

;; company
(use-package company
  :ensure t
  :custom
  (company-idle-delay 0.5)
  (company-show-numbers t)
  (company-tooltip-align-annotations t)
  (company-minimum-prefix-length 3)
  :config
  (global-company-mode)
  (add-to-list 'company-transformers #'company-sort-by-occurrence)
  :bind
  (:map company-active-map
	("M-n" . nil)
	("M-p" . nil)
	("C-n" . #'company-select-next)
	("C-p" . #'company-select-previous)))

;; ycmd
(use-package ycmd
  :if (not (eq system-type 'windows-nt))
  :ensure t
  :custom
  (ycmd-server-command `("python" ,(file-truename "~/github/ycmd/ycmd/")))
  :hook
  ((c-mode c++-mode) . ycmd-mode))

;; comany-ycmd
(use-package company-ycmd
  :if (not (eq system-type 'windows-nt))
  :ensure t
  :hook (ycmd-mode . company-ycmd-setup))

;; flycheck-ycmd
(use-package flycheck-ycmd
  :if (not (eq system-type 'windows-nt))
  :ensure t
  :hook (ycmd-mode . flycheck-ycmd-setup))

;; flycheck
(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode))

;; hungry-delete
(use-package hungry-delete
  :ensure t
  :config
  (global-hungry-delete-mode))

;; ledger-mode
(use-package ledger-mode
  :ensure t
  :mode "\\.ledger$")

;; magit
(use-package magit
  :ensure t
  :bind
  (("C-x g" . magit-status)))

;; popwin
(use-package popwin
  :ensure t
  :config (popwin-mode 1))

;; smartparens
(use-package smartparens
  :ensure t
  :init (require 'smartparens-config)
  :hook (prog-mode . smartparens-mode))

;; counsel
(use-package counsel
  :ensure t)

;; swiper
(use-package swiper
  :after (counsel)
  :ensure t
  :config
  (ivy-mode 1)
  (counsel-mode 1)
  :bind
  (("\C-s" . swiper)
   ("C-c C-r" . ivy-resume)
   :map minibuffer-local-map
   ("C-r" . counsel-minibuffer-history))
  :custom
  (ivy-use-virtual-buffers t)
  (enable-recursive-minibuffers t))

;; solarized-theme
(use-package solarized-theme
  :ensure t
  :config
  (load-theme 'solarized-dark t))

;; which-key
(use-package which-key
  :ensure t
  :init
  (which-key-mode)
  :config
  (which-key-setup-side-window-right-bottom))

;; pyim Chinese input method
(use-package pyim
  :ensure t
  :demand t
  :config
  ;; 激活 basedict 拼音词库
  (use-package pyim-basedict
    :ensure t
    :config (pyim-basedict-enable))

  (setq default-input-method "pyim")

  ;; 我使用全拼
  (setq pyim-default-scheme 'quanpin)

  ;; 设置 pyim 探针设置，这是 pyim 高级功能设置，可以实现 *无痛* 中英文切换 :-)
  ;; 我自己使用的中英文动态切换规则是：
  ;; 1. 光标只有在注释里面时，才可以输入中文。
  ;; 2. 光标前是汉字字符时，才能输入中文。
  ;; 3. 使用 M-j 快捷键，强制将光标前的拼音字符串转换为中文。
  (setq-default pyim-english-input-switch-functions
                '(pyim-probe-dynamic-english
                  pyim-probe-isearch-mode
                  pyim-probe-program-mode
                  pyim-probe-org-structure-template))

  (setq-default pyim-punctuation-half-width-functions
                '(pyim-probe-punctuation-line-beginning
                  pyim-probe-punctuation-after-punctuation))

  ;; 开启拼音搜索功能
  (pyim-isearch-mode 1)

  ;; 使用 pupup-el 来绘制选词框, 如果用 emacs26, 建议设置
  ;; 为 'posframe, 速度很快并且菜单不会变形，不过需要用户
  ;; 手动安装 posframe 包。
  (setq pyim-page-tooltip 'popup)

  ;; 选词框显示5个候选词
  (setq pyim-page-length 5)

  ;; 让 Emacs 启动时自动加载 pyim 词库
  (add-hook 'emacs-startup-hook
            #'(lambda () (pyim-restart-1 t)))
  :bind
  (("M-j" . pyim-convert-code-at-point) ;与 pyim-probe-dynamic-english 配合
   ("C-." . pyim-delete-word-from-personal-buffer)))

(provide 'init)
;;; init.el ends here

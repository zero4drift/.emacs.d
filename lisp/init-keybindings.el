;; init-keybindgs.el

;; bindings for general utilization

;; shortcut to open init.el
(defun open-init()
  (interactive)
  (find-file "~/.emacs.d/init.el"))
(global-set-key (kbd "<f12>") 'open-init)

;; bindings for swiper
(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-ag)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)

;; bindings for recentf
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; bindings for magit
(global-set-key (kbd "C-x g") 'magit-status)

(provide 'init-keybindings)

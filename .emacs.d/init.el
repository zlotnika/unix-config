;;; summary --- init
;;; Commentary:
;; Install via Melpa:
;; auto-complete
;; flycheck
;; js2-mode
;; json-mode
;; magit
;; markdown-mode
;; python-mode
;; rspec-mode
;; stylus-mode
;; web-mode

;;; Code:
;;;;;;;;;;;;;
;; globals ;;
;;;;;;;;;;;;;

;; MELPA
;; list-packages i install x execute U update
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; flycheck
(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)

;; term
(add-hook 'term-mode-hook
          (lambda ()
            ;; C-x is the prefix command, rather than C-c
            (term-set-escape-char ?\C-x)
            (define-key term-raw-map "\M-y" 'yank-pop)
                 (define-key term-raw-map "\M-w" 'kill-ring-save)))

;;;; tabs ;;;;
;; spaces instead of tabs
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq-default c-basic-offset 2)
;; in text mode, use 2 space tabs like not a crazy person
(setq-default indent-line-function 'insert-tab)

;;;; backups ;;;;
;; Write backups to ~/.emacs.d/backup/
(setq backup-directory-alist '((".*" . "~/.emacs.d/backup"))
      backup-by-copying      t  ; Don't de-link hard links
      version-control        t  ; Use version numbers on backups
      delete-old-versions    t  ; Automatically delete excess backups:
      kept-new-versions      20 ; how many of the newest versions to keep
      kept-old-versions      5) ; and how many of the old
;; Write saves to temporary directory ( /var/ something )
(setq auto-save-file-name-transforms
      `((".*" "~/.emacs.d/backup" t)))
;; don't create .# files
(setq create-lockfiles nil)

;; work well with git
(global-auto-revert-mode t)
(setq require-final-newline t)

;; clean up whitespace
(add-hook 'before-save-hook 'whitespace-cleanup)

;;;; interface ;;;;
;; visual bell
(setq visible-bell t)

;; auto-complete
(global-auto-complete-mode t)
;; http://stackoverflow.com/questions/15637536/how-do-i-preserve-capitalization-when-using-autocomplete-in-emacs
(setq ac-ignore-case nil)

;; remove extra ui
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(setq column-number-mode t)

;; automatic pairs
;; (electric-pair-mode 1)

;; make it big
(set-frame-font "Andale Mono-18")

(load-theme 'abyss t)

;; highlight the current line
(add-hook 'prog-mode-hook #'hl-line-mode)

;; rainbow (())
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;;;;;;;;;;;
;; Modes ;;
;;;;;;;;;;;

;; shell ;;
(setq-default sh-basic-offset 2)
(setq-default sh-indentation 2)

;; ruby ;;
(setq ruby-deep-indent-paren nil)
(setq ruby-deep-indent-paren-style nil)
(setq compilation-scroll-output t)
(add-to-list 'auto-mode-alist '("\\Gemfile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\Rakefile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\Guardfile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake\\'" . ruby-mode))

;; rspec ;;
(setq rspec-use-vagrant-when-possible t)

;; conf ;;
(add-to-list 'auto-mode-alist '("\\Gemfile.lock\\'" . conf-mode))

;; apache ;;
(add-to-list 'auto-mode-alist '("\\.vhost\\'" . apache-mode))

;; yml ;;
(add-to-list 'auto-mode-alist '("\\.yml.example\\'" . yaml-mode))

;; json ;;
(add-to-list 'auto-mode-alist '("\\.jshintrc\\'" . json-mode))
(add-to-list 'auto-mode-alist '("\\.jscsrc\\'" . json-mode))
(add-to-list 'auto-mode-alist '("\\.ember-cli\\'" . json-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-mode))

;; css ;;
(setq css-indent-offset 2)
(add-to-list 'auto-mode-alist '("\\.scss\\'" . sass-mode))
(add-to-list 'auto-mode-alist '("\\.sass\\'" . sass-mode))

;; markdown ;;
;;(add-hook 'markdown-mode-hook #'flyspell-mode)
(add-to-list 'auto-mode-alist '("\\.txt\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.mkd\\'" . markdown-mode))

;; handlebars ;;
(require 'web-mode)
(setq web-mode-markup-indent-offset 2)
(setq web-mode-enable-auto-pairing t)
(setq web-mode-enable-current-element-highlight t)
(setq web-mode-enable-current-column-highlight t)
(add-to-list 'auto-mode-alist '("\\.hbs\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))

;; javascript ;;
(setq javascript-indent-level 2)
(setq js-indent-level 2)
(setq js2-basic-offset 2)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.js.erb\\'" . js2-mode))
(eval-after-load 'js-mode
     '(add-hook 'js-mode-hook (lambda () (add-hook 'after-save-hook 'eslint-fix nil t))))
(eval-after-load 'js2-mode
     '(add-hook 'js2-mode-hook (lambda () (add-hook 'after-save-hook 'eslint-fix nil t))))

;; go ;;
(require 'go-mode)
(setq gofmt-command "goimports")
(add-hook 'before-save-hook #'gofmt-before-save)

;; bazel ;;
(require 'bazel-mode)
(add-to-list 'auto-mode-alist '("BUILD" . bazel-mode))

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("551596f9165514c617c99ad6ce13196d6e7caa7035cea92a0e143dbe7b28be0e" "19352d62ea0395879be564fc36bc0b4780d9768a964d26dfae8aad218062858d" default)))
 '(package-selected-packages
   (quote
    (abyss-theme rainbow-delimiters flycheck-gometalinter bazel-mode protobuf-mode go-mode dockerfile-mode eslint-fix git-link sass-mode json-mode gitignore-mode haml-mode yaml-mode web-mode stylus-mode ssh-config-mode ruby-end rspec-mode python-mode markdown-mode magit jscs js2-mode gitconfig-mode flycheck auto-complete apache-mode)))
 '(send-mail-function (quote sendmail-send-it)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "black" :foreground "WhiteSmoke" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 180 :width normal :foundry "nil" :family "Andale Mono")))))

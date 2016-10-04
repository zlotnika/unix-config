;;; summary --- init
;;; Commentary:
;; Install via Melpa:
;; auto-complete
;; flycheck
;; js2-mode
;; jscs
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

;; automatic pairs
;; (electric-pair-mode 1)

;;;;;;;;;;;
;; Modes ;;
;;;;;;;;;;;

;; ruby ;;
(setq ruby-deep-indent-paren nil)
(setq ruby-deep-indent-paren-style nil)
(add-to-list 'auto-mode-alist '("\\Gemfile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\Rakefile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\Guardfile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake\\'" . ruby-mode))
(setq compilation-scroll-output t)

;; conf ;;
(add-to-list 'auto-mode-alist '("\\Gemfile.lock\\'" . conf-mode))

;; apache ;;
(add-to-list 'auto-mode-alist '("\\.vhost\\'" . apache-mode))

;; json ;;
(add-to-list 'auto-mode-alist '("\\.jshintrc\\'" . json-mode))
(add-to-list 'auto-mode-alist '("\\.jscsrc\\'" . json-mode))
(add-to-list 'auto-mode-alist '("\\.ember-cli\\'" . json-mode))

;; css ;;
(setq css-indent-offset 2)
(add-to-list 'auto-mode-alist '("\\.scss\\'" . css-mode))

;; markdown ;;
(add-hook 'markdown-mode-hook #'flyspell-mode)
(add-to-list 'auto-mode-alist '("\\.txt\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; handlebars ;;
(require 'web-mode)
(setq web-mode-markup-indent-offset 2)
(add-to-list 'auto-mode-alist '("\\.hbs\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(setq web-mode-enable-auto-pairing t)
(setq web-mode-enable-current-element-highlight t)
(setq web-mode-enable-current-column-highlight t)

;; javascript ;;
(setq javascript-indent-level 2)
(setq js-indent-level 2)
(setq js2-basic-offset 2)
(add-to-list 'auto-mode-alist '("\\.js.erb\\'" . javascript-mode))
(add-hook 'js2-mode-hook #'jscs-indent-apply)
(add-hook 'js2-mode-hook #'jscs-fix-run-before-save)

;; js2 ;;
;; https://yoo2080.wordpress.com/2012/03/15/js2-mode-setup-recommendation/
(add-to-list 'auto-mode-alist (cons (rx ".js" eos) 'js2-mode))
;; (add-hook 'js2-mode-hook 'my-disable-indent-tabs-mode)
;; (defun my-disable-indent-tabs-mode ()
;;     (set-variable 'indent-tabs-mode nil))
;; (eval-after-load "js2-mode"
;;   '(progn
;;      (setq js2-missing-semi-one-line-override t)
;;      (setq-default js2-basic-offset 2) ; 2 spaces for indentation (if you prefer 2 spaces instead of default 4 spaces for tab)

;;      ;; add from jslint global variable declarations to js2-mode globals list
;;      ;; modified from one in http://www.emacswiki.org/emacs/Js2Mode
;;      (defun my-add-jslint-declarations ()
;;        (when (> (buffer-size) 0)
;;          (let ((btext (replace-regexp-in-string
;;                        (rx ":" (* " ") "true") " "
;;                        (replace-regexp-in-string
;;                         (rx (+ (char "\n\t\r "))) " "
;;                         ;; only scans first 1000 characters
;;                         (save-restriction (widen) (buffer-substring-no-properties (point-min) (min (1+ 1000) (point-max)))) t t))))
;;            (mapc (apply-partially 'add-to-list 'js2-additional-externs)
;;                  (split-string
;;                   (if (string-match (rx "/*" (* " ") "global" (* " ") (group (*? nonl)) (* " ") "*/") btext)
;;                       (match-string-no-properties 1 btext) "")
;;                   (rx (* " ") "," (* " ")) t))
;;            )))
;;           (add-hook 'js2-post-parse-callbacks 'my-add-jslint-declarations)))

;; Flycheck JSCS
;; (flycheck-def-config-file-var flycheck-jscs javascript-jscs ".jscsrc"
;;   :safe #'stringp)
;; (flycheck-define-checker javascript-jscs
;;   "A JavaScript code style checker.
;; See URL `https://github.com/mdevils/node-jscs'."
;;   :command ("jscs" "--reporter" "checkstyle"
;;             (config-file "--config" flycheck-jscs)
;;             source)
;;   :error-parser flycheck-parse-checkstyle
;;   :modes (js-mode js2-mode js3-mode)
;;   :next-checkers (javascript-jshint))
;; (defun jscs-enable () (interactive)
;;        (add-to-list 'flycheck-checkers 'javascript-jscs))
;; (defun jscs-disable () (interactive)
;;        (setq flycheck-checkers (remove 'javascript-jscs flycheck-checkers)))

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("19352d62ea0395879be564fc36bc0b4780d9768a964d26dfae8aad218062858d" default)))
 '(package-selected-packages
   (quote
    (yaml-mode web-mode stylus-mode ssh-config-mode ruby-end rspec-mode python-mode markdown-mode magit jscs js2-mode gitconfig-mode flycheck auto-complete apache-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

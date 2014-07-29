;;; plugins-config --- configuration specific to plugins

;;; Code:
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;;; from purcell/emacs.d
;;; helper to require and download plugins automatically
(defun require-package (package &optional min-version no-refresh)
  "Install given PACKAGE, optionally requiring MIN-VERSION.
  If NO-REFRESH is non-nil, the available package lists will not be
  re-downloaded in order to locate PACKAGE."
  (if (package-installed-p package min-version)
      t
    (if (or (assoc package package-archive-contents) no-refresh)
        (package-install package)
      (progn
        (package-refresh-contents)
        (require-package package min-version t)))))

;;; plugins
(require-package 'evil)
(require-package 'color-theme-solarized)
(require-package 'rainbow-delimiters)
(require-package 'yasnippet)
(require-package 'auto-complete)
(require-package 'flycheck)
(require-package 'go-mode)

;;; monkey-patch solarized colors to fix brightblack and load the theme
(require 'solarized-definitions)
(setq solarized-colors (mapcar (lambda(lst)
                                 (mapcar (lambda(color)
                                           (if (string= color "brightblack")
                                               nil
                                             color
                                             )) lst)) solarized-colors))
(load-theme 'solarized-dark t)

(add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)

;;; enable yasnippet completions in auto-complete
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)

;;; enable yasnippet globally
(yas-global-mode 1)

;;; enable flycheck globally
(add-hook 'after-init-hook #'global-flycheck-mode)

;;; enable evil mode
(evil-mode t)

(setq evil-search-module 'evil-search
      evil-want-C-u-scroll t
      evil-want-C-w-in-emacs-state t)

;;;; Define custom escape sequence for evil-mode
(define-key evil-insert-state-map "k" #'cofi/maybe-exit)
(evil-define-command cofi/maybe-exit ()
  :repeat change
  (interactive)
  (let ((modified (buffer-modified-p)))
    (insert "k")
    (let ((evt (read-event (format "Insert %c to exit insert state" ?j)
                           nil 0.25)))
      (cond
       ((null evt) (message ""))
       ((and (integerp evt) (char-equal evt ?j))
        (delete-char -1)
        (set-buffer-modified-p modified)
        (push 'escape unread-command-events))
       (t (setq unread-command-events (append unread-command-events
                                              (list evt))))))))


(provide 'plugins-config)
;;; plugins-config.el ends here

;;; load plugins
(add-to-list 'load-path "~/.emacs.d/custom")
(require 'plugins-config)

;;; Hide the menubar
(menu-bar-mode -1)

;;; Enable line numbers that don't look terrible
(global-linum-mode t)
(setq linum-format "%3d ")

;;; Use spaces for indent
(setq-default indent-tabs-mode nil)

(setq
   backup-by-copying t               ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.emacs.d/backups"))  ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)                ; use versioned backups


(provide 'init)
;;; init.el ends here

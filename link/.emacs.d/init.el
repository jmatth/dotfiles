(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes (quote ("3a727bdc09a7a141e58925258b6e873c65ccf393b2240c51553098ca93957723" "756597b162f1be60a12dbd52bab71d40d6a2845a3e3c2584c6573ee9c332a66e" "6a37be365d1d95fad2f4d185e51928c789ef7a4ccf17e7ca13ad63a8bf5b922f" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

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

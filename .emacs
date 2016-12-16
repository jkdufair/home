;; package --- Summary
;; Jason Dufair's .emacs

;; Commentary:
;; Keep it light

;; Code:

(add-hook 'emacs-startup-hook 'toggle-frame-maximized)
(add-to-list 'load-path "~/.emacs.d/elisp/")
(load-library "typography")
;;(load-library "flow")

(package-initialize)

(setq-default indent-tabs-mode t)

(setq mac-command-modifier 'meta)
(setq x-select-enable-clipboard t)
(global-set-key "\M-`" 'other-frame)
(global-auto-revert-mode)
(tool-bar-mode -1)
(setenv "PATH" (concat "/usr/local/bin:" (getenv "PATH")))
(savehist-mode 1)

;;
;; ido
;;
(ido-mode t)
(setq ido-use-filename-at-point 'guess)
(ido-everywhere 1)
(flx-ido-mode 1)
;; disable ido faces to see flx highlights.
(setq ido-use-faces nil)


;;
;; Projectile
;;
(add-hook 'after-init-hook 'projectile-mode)
(setq projectile-switch-project-action 'projectile-dired)


;;
;; Dired
;;
(require 'dired)
(put 'dired-find-alternate-file 'disabled nil)
(setq dired-use-ls-dired nil)
(defun mydired-sort ()
  "Sort dired listings with directories first."
  (save-excursion
    (let (buffer-read-only)
      (forward-line 2) ;; beyond dir. header 
      (sort-regexp-fields t "^.*$" "[ ]*." (point) (point-max)))
    (set-buffer-modified-p nil)))

(defadvice dired-readin
  (after dired-after-updating-hook first () activate)
  "Sort dired listings with directories first before adding marks."
  (mydired-sort))

(defun dired-open-file ()
  "In dired, open the file named on this line."
  (interactive)
  (let* ((file (dired-get-filename nil t)))
    (call-process "open" nil 0 nil file)))
(define-key dired-mode-map (kbd "C-c o") 'dired-open-file)

;;
;; Keyboard bindings
;;
;; Multiple cursors
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
;; Magit
(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-x v b") 'magit-blame)
;;
(defun revert-buffer-no-confirm ()
    "Revert buffer without confirmation."
    (interactive)
    (revert-buffer :ignore-auto :noconfirm))
(global-set-key (kbd "C-c r") 'revert-buffer-no-confirm)

;;
;; Tabs
;;
(setq-default indent-tabs-mode t)
(setq-default tab-width 2)

(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

;;
;; Electric pair
;;
(add-hook
 'prog-mode-hook
 (lambda ()
	 (electric-pair-mode 1)))


;;
;; Yasnippet
;;
(require 'yasnippet)
(yas-reload-all)
(add-hook 'prog-mode-hook #'yas-minor-mode)
(add-to-list 'load-path "~/.emacs.d/es6-snippets")

(load-theme 'zenburn t)

;;
;; Company mode
;;
(add-hook 'after-init-hook 'global-company-mode)

;;
;; JS/JSX development
;;

(setq js-indent-level 2)

;;
;; Markdown
;;
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))

;;
;; Tern
;;
(autoload 'tern-mode "tern.el" nil t)
(eval-after-load 'company
	'(add-to-list 'company-backends 'company-tern))



;; use web-mode for .jsx files
(add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))
(add-hook 'web-mode-hook
					(lambda ()
						(delete-trailing-whitespace)
						(web-mode-use-tabs)
						(setq web-mode-code-indent-offset 2)
						(setq web-mode-css-indent-offset 1)
						(tern-mode t)))

;; use js2-mode for regular .js
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-hook 'js2-mode-hook
					(lambda ()
						(delete-trailing-whitespace)
						(tern-mode t)))

;; http://www.flycheck.org/manual/latest/index.html
(require 'flycheck)

;; turn on flychecking globally
(add-hook 'after-init-hook #'global-flycheck-mode)

;; disable jshint since we prefer eslint checking
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
					'(javascript-jshint json-jsonlist)))

;; use eslint with web-mode for jsx files
(flycheck-add-mode 'javascript-eslint 'web-mode)

;; customize flycheck temp file prefix
(setq-default flycheck-temp-prefix ".flycheck")


;; for better jsx syntax-highlighting in web-mode
;; - courtesy of Patrick @halbtuerke
(defadvice web-mode-highlight-part (around tweak-jsx activate)
  (if (equal web-mode-content-type "jsx")
    (let ((web-mode-enable-part-face nil))
      ad-do-it)
    ad-do-it))

(defun my/use-eslint-from-node-modules ()
  (let* ((root (locate-dominating-file
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (eslint (and root
                      (expand-file-name "node_modules/eslint/bin/eslint.js"
                                        root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))

(add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules)

;; https://github.com/purcell/exec-path-from-shell
;; only need exec-path-from-shell on OSX
;; this hopefully sets up path and other vars better
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))


;;
;; Dired to CSV for Tam
;;
(defun convert-dired-date-for-csv (date-string)
	"Convert DATE-STRING from dired (Nov 8 2015) to 11/8/2015."
 (let ((parsed-time (parse-time-string date-string)))
	(concat (number-to-string (nth 4 parsed-time))
					"/"
					(number-to-string (nth 3 parsed-time))
					"/"
					(number-to-string (nth 5 parsed-time)))))

(defun dired-to-csv ()
	"Take dired output and generate records for CSV."
	(interactive)
	(let ((drive-name (read-string "Enter drive name: "))
				(photographer (read-string "Who shot it: "))
				(buffer-line-count (count-lines (point-min) (point-max))))
		(beginning-of-buffer)
		(dotimes (i buffer-line-count)
			(set-mark-command nil)
			(forward-sexp 6)
			(backward-sexp)
			(kill-region (mark) (point))
			(deactivate-mark)
			(insert drive-name "," photographer ",")
			(set-mark-command nil)
			(forward-sexp 3)
			(let ((converted-date (convert-dired-date-for-csv (buffer-substring (mark) (point)))))
				(kill-region (mark) (point))
				(deactivate-mark)
				(insert converted-date))
			(insert ",")
			(delete-char 1)
			(move-beginning-of-line nil)
			(and (< i (- buffer-line-count 1))
					 (next-line)))))

(global-set-key (kbd "C-c d") 'dired-to-csv)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
	 (quote
		("b9e9ba5aeedcc5ba8be99f1cc9301f6679912910ff92fdf7980929c2fc83ab4d" "84d2f9eeb3f82d619ca4bfffe5f157282f4779732f48a5ac1484d94d5ff5b279" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" default)))
 '(magit-merge-arguments nil)
 '(package-selected-packages
	 (quote
		(smart-mode-line smart-mode-line-powerline-theme hide-lines csv-mode csharp-mode js-comint cypher-mode markdown-mode magit yasnippet flx-ido company-tern js2-mode tern-auto-complete tern zenburn-theme web-mode projectile json-mode js2-refactor flycheck f exec-path-from-shell dash-functional)))
 '(save-place t)
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(region ((t (:background "dark cyan")))))
(put 'narrow-to-region 'disabled nil)

(setq sml/theme 'powerline)
(sml/setup)


(provide '.emacs)
;; .emacs ends here

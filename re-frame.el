(require 'parseclj)
(require 'ivy)
(require 'dash)

(defun re-frame-parse-project ()
  (setq re-frame--parsed-project
	(let ((project-root (projectile-project-root)))
	  (cl-loop for file in (--filter
				(and
				 (not (eq nil it))
				 (s-contains? "cljs" it))
				(projectile-current-project-files))
		   for ast = (with-temp-buffer
			       (insert-file-contents (concat project-root file))
			       (parseclj-parse-clojure))
		   append (re-frame--events-data ast (concat project-root file))))))

(defun re-frame--events-data (ast filename)
  (-let (((&alist :children ((&alist :children (_ (&alist :form ns))))) ast))
    (-keep (lambda (form-elt)
    	     (-if-let* (((&alist :position position :children
    				 ((&alist :node-type first-type :form first-form)
    				  (&alist :node-type second-type :form second-form)))
    			 form-elt))
    		 (and (eql first-type :symbol)
    		      (-contains? (list "reg-event-db" "reg-event-fx") first-form)
    		      (cons (concat ns second-form) (list position first-form filename)))))
    	   (alist-get :children ast))))

(defun re-frame-search-events ()
  (interactive)
  (if re-frame--parsed-project
      (-let (((_ . (position _ file)) (assoc (ivy-read
						"Found %d events: "
						re-frame--parsed-project)
					     re-frame--parsed-project)))
	(find-file file)
	(goto-char position))
    (when (y-or-n-p "Parsing project may take a while. OK?")
      (re-frame-parse-project))))

(provide 're-frame)

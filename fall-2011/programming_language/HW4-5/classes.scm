(module classes (lib "eopl.ss" "eopl")

  (require "store.scm")
  (require "lang.scm")
  ;(require "environments.scm")

  ;; object interface
  (provide object object? new-object object->class-name object->fields)

  ;; method interface
  (provide method method? a-method find-method find-method-modifier)
  
  ;; class interface
  (provide lookup-class the-class-env class->static-field-names initialize-class-env!)

;;;;;;;;;;;;;;;; objects ;;;;;;;;;;;;;;;;

  ;; an object consists of a symbol denoting its class, and a list of
  ;; references representing the managed storage for the all the fields. 
  
  (define identifier? symbol?)

  (define-datatype object object? 
    (an-object
      (class-name identifier?)
      (fields (list-of reference?))))

  ;; new-object : ClassName -> Obj
  ;; Page 340
  (define new-object                      
    (lambda (class-name)
      (an-object
        class-name
        (map 
          (lambda (field-name)
            (newref (list 'uninitialized-field field-name)))
          (class->field-names (lookup-class class-name))))))

;;;;;;;;;;;;;;;; methods and method environments ;;;;;;;;;;;;;;;;

  (define-datatype method method?
    (a-method
      (vars (list-of symbol?))
      (body expression?)
      (super-name symbol?)
      (field-names (list-of symbol?))))

;;;;;;;;;;;;;;;; method environments ;;;;;;;;;;;;;;;;

  ;; a method environment looks like ((method-name method) ...)

  (define method-environment?
    (list-of 
      (lambda (p)
        (and 
          (pair? p)
          (symbol? (car p)) ;;; method name. used by assq function, should be first one. 
          (symbol? (cadr p)) ;;; modifier. 
          (method? (caddr p)))))) ;; body of method.

  ;; method-env * id -> (maybe method)
  (define assq-method-env
    (lambda (m-env id)
      (cond
        ((assq id m-env) => cadr)
        (else #f))))

  ;; find-method : Sym * Sym -> Method
  ;; Page: 345
  (define find-method
    (lambda (c-name name)
      (let ((m-env (class->method-env (lookup-class c-name))))
        (let ((maybe-pair (assq name m-env)))
          (if (pair? maybe-pair) (caddr maybe-pair)
            (report-method-not-found name))))))
  
  ;; find-method for final method declaration so that '() 
  ;; will be returned rather than an error emitted if no method found. 
  (define find-method-for-final
    (lambda (c-name name)
      (let ((m-env (class->method-env (lookup-class c-name))))
        (let ((maybe-pair (assq name m-env)))
          (if (pair? maybe-pair) (caddr maybe-pair)
              '())))))
  
  ;;; find-method-modifier : c-name x name -> modifier.
  (define find-method-modifier
    (lambda (c-name name)
      (if (not (null? (find-method c-name name)))
          (let ((m-env (class->method-env (lookup-class c-name))))
            (let ((maybe-pair (assq name m-env)))
              (if (not (null? maybe-pair))
                  (cadr maybe-pair)))))))
    
  (define report-method-not-found
    (lambda (name)
      (eopl:error 'find-method "unknown method ~s" name)))
  
  (define report-unauthorized-call
    (lambda (name)
      (eopl:error "operation ~s not permited!" name)))
  
  ;; merge-method-envs : MethodEnv * MethodEnv -> MethodEnv
  ;; Page: 345
  (define merge-method-envs
    (lambda (super-m-env new-m-env)
;      (display "\n\nMerging method-envs........")
;      (display new-m-env)
;      (display "Merging method-envsxxxxxxxxxxxx\n\n")
      (append new-m-env super-m-env)))

  ;; method-decls->method-env :
  ;; Listof(MethodDecl) * ClassName * Listof(FieldName) -> MethodEnv
  ;; Page: 345
  (define method-decls->method-env
    (lambda (m-decls super-name field-names)
      (map
        (lambda (m-decl)
          (cases method-decl m-decl
            (a-method-decl (method-name vars body)
              ;; find all the super calls and check its super class if 
              ;; the call is proper. 
              (method-modifier-check super-name body)
              (method-final-check super-name method-name)
              (list method-name 'public
                (a-method vars body super-name field-names)))
            
            ;; added with modifiers private, public and final. 
            (a-private-method-decl (method-name vars body)
                  (method-modifier-check super-name body)
                  (method-final-check super-name method-name)
                  (list method-name 'private
                        (a-method vars body super-name field-names)))
            (a-protected-method-decl (method-name vars body)
                  (method-modifier-check super-name body)
                  (method-final-check super-name method-name)
                  (list method-name 'protected
                  (a-method vars body super-name field-names)))
            (a-final-method-decl (method-name vars body)                                 
                  (method-final-check super-name method-name)
                  (list method-name 'final
                        (a-method vars body super-name field-names)))))
        m-decls)))
  
  ;;; method-modifier-check : super-name x m-body -> (pass or error.)
  ;; This method will check with the super method call to make sure
  ;; they are not private.
  (define method-modifier-check
    (lambda (super-name m-body)
      (cases expression m-body
        (super-call-exp (method-name rands)
                        (if (eqv? (find-method-modifier super-name method-name) 'private)
                            (eopl:error "Private method in super class ~s" method-name)))
        (begin-exp (exp1 exps)
                   (letrec ((check-modifier
                             (lambda (exp-lst)
                               (if (not (null? exp-lst))
                                   (begin
                                     (cases expression (car exp-lst)
                                       (super-call-exp (method-name rands)
                                                       (if (eqv? (find-method-modifier super-name method-name) 'private)
                                                           (eopl:error "Private method in super class ~s" method-name)))
                                       (else ()))
                                     (check-modifier (cdr exp-lst)))))))
                     (check-modifier (cons exp1 exps))))
        (else ()))))
  
  ;;; check if a defined method has final method defined in super class? 
  (define method-final-check
    (lambda (s-name m-name)
      (let ((m (find-method-for-final s-name m-name)))
        (if (and (not (null? m)) (eqv? (find-method-modifier s-name m-name) 'final))
            (eopl:error "Error: trying to overload a final function ~s" m-name)))))
  
  ;;;;;;;;;;;;;;;; classes ;;;;;;;;;;;;;;;;

  (define-datatype class class?
    (a-class
      (super-name (maybe symbol?))
      (field-names (list-of symbol?))
      (method-env method-environment?)
      (static-field-names (list-of list?))))

  ;;;;;;;;;;;;;;;; class environments ;;;;;;;;;;;;;;;;

  ;; the-class-env will look like ((class-name class) ...)

  ;; the-class-env : ClassEnv
  ;; Page: 343
  (define the-class-env '())

  ;; add-to-class-env! : ClassName * Class -> Unspecified
  ;; Page: 343
  (define add-to-class-env!
    (lambda (class-name class)
      (set! the-class-env
        (cons
          (list class-name class)
          the-class-env))))

  ;; lookup-class : ClassName -> Class
  (define lookup-class                    
    (lambda (name)
      (let ((maybe-pair (assq name the-class-env)))
        (if maybe-pair (cadr maybe-pair)
          (report-unknown-class name)))))

  (define report-unknown-class
    (lambda (name)
      (eopl:error 'lookup-class "Unknown class ~s" name)))
      
  ;; constructing classes

  ;; initialize-class-env! : Listof(ClassDecl) -> Unspecified
  ;; Page: 344
  (define initialize-class-env!
    (lambda (c-decls)
      (set! the-class-env 
        (list
          (list 'object (a-class #f '() '() '())))) ;; added '() for sf-names for hw5.
      (for-each initialize-class-decl! c-decls)))

  ;; initialize-class-decl! : ClassDecl -> Unspecified
  (define initialize-class-decl!
    (lambda (c-decl)
      (cases class-decl c-decl
        (a-class-decl (c-name s-name sf-names f-names m-decls) ;; added sf-names (static fields) for hwk5. 
          (let ((f-names
                 (append-field-names
                  (class->field-names (lookup-class s-name))
                  f-names))
                ;; append the store location to the static fields so that it can be easily applied
                ;; to envs during the evaluation process. --> hw5. 
                (sf-names  
                 (cons sf-names (cons (map
                   (lambda (sf-name)
                     (newref 0)) ;(num-val 0))) ;; num-val problem, can access constructor. 
                   sf-names) '()))))
            (add-to-class-env!
              c-name
              (a-class s-name f-names
                (merge-method-envs
                  (class->method-env (lookup-class s-name)) ; get env of super class.
                  (method-decls->method-env ;; get env of new class. 
                   ;; added sf-names static fields to the end of strcture so that it will not affect the 
                   ;; interpretation of methods. hw5.
                    m-decls s-name f-names)) sf-names))))))) 

  ;; exercise:  rewrite this so there's only one set! to the-class-env.

  ;; append-field-names :  Listof(FieldName) * Listof(FieldName) 
  ;;                       -> Listof(FieldName)
  ;; Page: 344
  ;; like append, except that any super-field that is shadowed by a
  ;; new-field is replaced by a gensym
  (define append-field-names
    (lambda (super-fields new-fields)
      (cond
        ((null? super-fields) new-fields)
        (else
         (cons 
           (if (memq (car super-fields) new-fields)
             (fresh-identifier (car super-fields))
             (car super-fields))
           (append-field-names
             (cdr super-fields) new-fields))))))

;;;;;;;;;;;;;;;; selectors ;;;;;;;;;;;;;;;;

  (define class->super-name
    (lambda (c-struct)
      (cases class c-struct
        (a-class (super-name field-names method-env sf-names);;added sf-names for hw5.
          super-name))))

  (define class->field-names
    (lambda (c-struct)
      (cases class c-struct
        (a-class (super-name field-names method-env sf-names);; added sf-names for hw5.
          field-names))))
  
  ;; function to get static fields. 
  (define class->static-field-names
    (lambda (c-struct)
      (cases class c-struct
        (a-class (super-name field-names method-env sf-names);; added sf-names for hw5.
          sf-names))))

  (define class->method-env
    (lambda (c-struct)
      (cases class c-struct
        (a-class (super-name field-names method-env sf-names);; added sf-names for hw5.
          method-env))))


  (define object->class-name
    (lambda (obj)
      (cases object obj
        (an-object (class-name fields)
          class-name))))

  (define object->fields
    (lambda (obj)
      (cases object obj
        (an-object (class-decl fields)
          fields))))

  (define fresh-identifier
    (let ((sn 0))
      (lambda (identifier)  
        (set! sn (+ sn 1))
        (string->symbol
          (string-append
            (symbol->string identifier)
            "%"             ; this can't appear in an input identifier
            (number->string sn))))))

  (define maybe
    (lambda (pred)
      (lambda (v)
        (or (not v) (pred v)))))

  )
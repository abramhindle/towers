;;;; +----------------------------------------------------------------+
;;;; | TOWERS - A silly geoDefense clone wannabe          DEATH, 2009 |
;;;; +----------------------------------------------------------------+
;;;;
;;;; Subject: Re: Lack of License [death/towers GH-1]
;;;; 
;;;; I hereby dedicate Towers to public domain.
;;;; 
;;;; In other words, you can do whatever you want with it.  I disclaim any liability.  I provide no warranty of any kind.  It's as if it just popped into existence.
;;;; 
;;;; If these statements don't make my intent clear, then the world is truly a seriously messed up place, and I have no more to say about that issue.
;;;; Parts of this code are under an MIT style license:
;;;; draw circle was derived from 
;;;;    http://github.com/sykopomp/until-it-dies/blob/master/src/primitives.lisp
;;;;
;;;; Tower Defense © 2009 Death, Abram Hindle(minor bug fix)
;;;; Until It Dies is Copyright © 2009 Josh Marchán, Adlai Chadrasekhar
;;;;  
;;;; Permission is hereby granted, free of charge, to any person obtaining a copy
;;;; of this software and associated documentation files (the "Software"), to deal
;;;; in the Software without restriction, including without limitation the rights
;;;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;;;; copies of the Software, and to permit persons to whom the Software is
;;;; furnished to do so, subject to the following conditions:
;;;;  
;;;; The above copyright notice and this permission notice shall be included in
;;;; all copies or substantial portions of the Software.
;;;;  
;;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;;;; SOFTWARE.


(defpackage #:towers
  (:use #:cl #:alexandria)
  (:export #:game #:randomgame))

(in-package #:towers)


;;;; Configuration

(defparameter *frames-per-second* 30)
(defparameter *tick-duration* (floor 1000 *frames-per-second*))
(defparameter *draw-collision-circle-for-type* 'nil)

(defparameter *data-directory*
  (let ((pathname (make-pathname :directory '(:relative "data"))))
    (if (find-package "ASDF")
        (let* ((system (funcall (find-symbol "FIND-SYSTEM" "ASDF") "towers"))
               (home (funcall (find-symbol "COMPONENT-PATHNAME" "ASDF") system)))
          (setf pathname (merge-pathnames pathname home)))
        pathname)))


(setf *random-state* (make-random-state t))


;;;; Utilities

(defconstant single-pi (coerce pi 'single-float))

(defun rad (deg)
  (/ (* single-pi deg) 180.0))

(defun deg (rad)
  (/ (* 180.0 rad) single-pi))

(defun normalize-deg (deg)
  (loop while (>= deg 360.0) do (decf deg 360.0))
  (loop while (< deg 0.0) do (incf deg 360.0))
  deg)

(defun sind (deg)
  (sin (rad deg)))

(defun cosd (deg)
  (cos (rad deg)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  ;; Yes, eval-when here is a hack.. drop when splitting file

  (defun collect-results (fn &rest args)
    (let ((collection '()))
      (apply fn
             (lambda (&rest results)
               (push results collection))
             args)
      (nreverse collection)))

  (defun call-with-circle-multipliers (fn &optional (segments 30))
    ;; http://github.com/sykopomp/until-it-dies/blob/master/src/primitives.lisp
    ;; Stole implementation of draw-circle and modified it a bit
    (let* ((theta (* 2.0 (/ single-pi segments)))
           (tangential-factor (tan theta))
           (radial-factor (- 1.0 (cos theta))))
      (loop with x = 1.0
            with y = 0.0
            repeat segments
            do (funcall fn x y)
            (let ((tx (- y))
                  (ty x))
              (incf x (* tx tangential-factor))
              (incf y (* ty tangential-factor)))
            (let ((rx (- x))
                  (ry (- y)))
              (incf x (* rx radial-factor))
              (incf y (* ry radial-factor)))))))

(define-compiler-macro draw-circle (&whole form radius &optional (segments 30) (filledp nil))
  (if (integerp segments)
      (once-only (radius)
        `(gl:with-primitives (if ,filledp :triangle-fan :line-loop)
           (loop for (x y) in ',(collect-results #'call-with-circle-multipliers segments)
                 do (gl:vertex (* ,radius x) (* ,radius y)))))
      form))
      
(defun draw-circle (radius &optional (segments 30) (filledp nil))
  (gl:with-primitives (if filledp :triangle-fan :line-loop)
    (call-with-circle-multipliers
     (lambda (x y) (gl:vertex (* x radius) (* y radius)))
     segments)))

(defun draw-pentagon (radius &optional (filledp nil)) (draw-circle radius 5 filledp))
(defun draw-hexagon (radius &optional (filledp nil)) (draw-circle radius 6 filledp))
(defun draw-pentagram (radius &optional (filledp nil)) 
	(draw-circle radius 30 filledp)
	(draw-star radius 5 2)
)
(defun draw-agram (points radius &optional (filledp nil)) 
	(draw-circle radius 30 filledp)
	(draw-star radius points 2)
)

(defun draw-triangle (radius &optional (filledp nil)) (draw-circle radius 3 filledp))
(defun draw-square (radius &optional (filledp nil)) (draw-circle radius 4 filledp))


(defun draw-heptagon 	 (radius &optional (filledp nil)) (draw-circle radius	7 filledp))
(defun draw-octagon 	 (radius &optional (filledp nil)) (draw-circle radius	8 	 filledp))
(defun draw-enneagon  	 (radius &optional (filledp nil)) (draw-circle radius	9 	 filledp))
(defun draw-decagon 	 (radius &optional (filledp nil)) (draw-circle radius	10 	 filledp))
(defun draw-hendecagon 	 (radius &optional (filledp nil)) (draw-circle radius	11 filledp))
(defun draw-dodecagon 	 (radius &optional (filledp nil)) (draw-circle radius	12 filledp))
(defun draw-tridecagon   (radius &optional (filledp nil)) (draw-circle radius	13  filledp))
(defun draw-tetradecagon (radius &optional (filledp nil)) (draw-circle radius  	14  filledp))
(defun draw-pentadecagon (radius &optional (filledp nil)) (draw-circle radius  	15  filledp))
(defun draw-hexadecagon  (radius &optional (filledp nil)) (draw-circle radius 	16  filledp))
(defun draw-heptadecagon (radius &optional (filledp nil)) (draw-circle radius  	17  filledp))
(defun draw-octadecagon  (radius &optional (filledp nil)) (draw-circle radius	18  filledp))
(defun draw-enneadecagon (radius &optional (filledp nil)) (draw-circle radius  	19  filledp))
(defun draw-icosagon	 (radius &optional (filledp nil)) (draw-circle radius	20 filledp))


(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun mod+ (n m p)
    (mod (+ n m) p))
  
  (defun call-with-star-multipliers (fn points density)
    (let ((xs (make-array points :element-type 'single-float))
          (ys (make-array points :element-type 'single-float)))
      (let ((i 0))
        (call-with-circle-multipliers
         (lambda (x y)
           (setf (aref xs i) x)
           (setf (aref ys i) y)
           (incf i))
         points))
      (dotimes (i points)
        (let ((j (mod+ i density points)))
          (funcall fn
                   (aref xs i) (aref ys i)
                   (aref xs j) (aref ys j)))))))

(define-compiler-macro draw-star (&whole form radius points density)
  (if (and (integerp points) (integerp density))
      (once-only (radius)
        `(gl:with-primitive :lines
           (loop for (x1 y1 x2 y2) in ',(collect-results #'call-with-star-multipliers points density) do
                 (gl:vertex (* ,radius x1) (* ,radius y1))
                 (gl:vertex (* ,radius x2) (* ,radius y2)))))
      form))

(defun draw-star (radius points density)
  (gl:with-primitive :lines
    (call-with-star-multipliers
     (lambda (x1 y1 x2 y2)
       (gl:vertex (* x1 radius) (* y1 radius))
       (gl:vertex (* x2 radius) (* y2 radius)))
     points density)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun call-with-curve-multipliers (fn &optional (segments 20))
    (funcall fn 1.0 0.0 0.0 0.0)
    (loop with step = (/ 1.0 segments)
          repeat (- segments 2)
          for u = step then (+ u step)
          for v = (- 1.0 u)
          for am = (* 1.0 v v v)
          for bm = (* 3.0 v v u)
          for cm = (* 3.0 v u u)
          for dm = (* 1.0 u u u)
          do (funcall fn am bm cm dm))
    (funcall fn 0.0 0.0 0.0 1.0)))

(define-compiler-macro draw-cubic-curve (&whole form ax ay bx by cx cy dx dy &optional (segments 20))
  (if (integerp segments)
      (once-only (ax ay bx by cx cy dx dy)
        `(gl:with-primitive :line-strip
           (loop for (am bm cm dm) in ',(collect-results #'call-with-curve-multipliers segments)
                 do (gl:vertex (+ (* am ,ax) (* bm ,bx) (* cm ,cx) (* dm ,dx))
                               (+ (* am ,ay) (* bm ,by) (* cm ,cy) (* dm ,dy))))))
      form))

(defun draw-cubic-curve (ax ay bx by cx cy dx dy &optional (segments 20))
  (gl:with-primitive :line-strip
    (call-with-curve-multipliers
     (lambda (am bm cm dm)
       (gl:vertex (+ (* am ax) (* bm bx) (* cm cx) (* dm dx))
                  (+ (* am ay) (* bm by) (* cm cy) (* dm dy))))
     segments)))

(defun square (x)
  (* x x))

(defun best-element (list &key (key #'identity) (test #'<))
  (assert list)
  (let ((best (first list))
        (best-key (funcall key (first list))))
    (dolist (x (rest list))
      (let ((key (funcall key x)))
        (when (funcall test key best-key)
          (setf best x best-key key))))
    (values best best-key)))

(defun cddddddr (cons) (cddddr (cddr cons)))

(defun nothing (&rest whatever)
  (declare (ignore whatever)))


;;;; 2D vectors

(defun vec (x y) (cons x y))

(defun x (vec) (car vec))

(defun y (vec) (cdr vec))

(defun (setf x) (new-x vec)
  (setf (car vec) new-x))

(defun (setf y) (new-y vec)
  (setf (cdr vec) new-y))

(defun copy-vec (v)
  (vec (x v) (y v)))

(defun vec-assign (v x y)
  (setf (x v) x)
  (setf (y v) y)
  v)

(defun unit (&optional (dir 0.0))
  (if (consp dir)
      (vec/ dir (vec-mag dir))
      (vec (sind dir) (cosd dir))))

(defun vec-clear (vec)
  (setf (x vec) 0.0)
  (setf (y vec) 0.0)
  vec)

(defun vec-mul (v1 v2)
  (+ (* (x v1) (x v2))
     (* (y v1) (y v2))))

(defun vec+ (v1 v2)
  (vec (+ (x v1) (x v2))
       (+ (y v1) (y v2))))

(defun vec+= (v1 v2)
  (incf (x v1) (x v2))
  (incf (y v1) (y v2))
  v1)

(defun vec- (v1 v2)
  (vec (- (x v1) (x v2))
       (- (y v1) (y v2))))

(defun vec-= (v1 v2)
  (decf (x v1) (x v2))
  (decf (y v1) (y v2))
  v1)

(defun vec* (v a)
  (vec (* (x v) a)
       (* (y v) a)))

(defun vec*= (v a)
  (setf (x v) (* (x v) a))
  (setf (y v) (* (y v) a))
  v)

(defun vec/ (v a)
  (vec (/ (x v) a)
       (/ (y v) a)))

(defun vec/= (v a)
  (setf (x v) (/ (x v) a))
  (setf (y v) (/ (y v) a))
  v)

(defun vec-mag (v)
  (sqrt (+ (square (x v)) (square (y v)))))

(defun vec-distance (v1 v2)
  (sqrt (vec-distance-sq v1 v2)))

(defun vec-distance-sq (v1 v2)
  (+ (square (- (x v1) (x v2)))
     (square (- (y v1) (y v2)))))

(defun vec-contains (v1 v2 &optional (r 1.0))
  (vec-contains-xy v1 (x v2) (y v2) r))

(defun vec-contains-xy (v x y &optional (r 1.0))
  (and (>= x (* (- (x v)) r))
       (<= x (* (x v) r))
       (>= y (* (- (y v)) r))
       (<= y (* (y v) r))))

(defmacro with-vec ((x y vec &optional (update nil)) &body forms)
  (once-only (vec)
    `(,(if update
           'symbol-macrolet
           'let)
       ((,x (car ,vec))
        (,y (cdr ,vec)))
       ,@forms)))

(defun vec=~ (v1 v2 &optional (epsilon 0.1))
  (flet ((=~ (a b) (< (abs (- a b)) epsilon)))
    (and (=~ (x v1) (x v2))
         (=~ (y v1) (y v2)))))

(defun vel-vec (mag dir)
  (vec*= (unit dir) mag))

(defun vec-angle (vec)
  (deg (atan (y vec) (x vec))))


;;;; Wavefront objects

(defclass wf-object ()
  ((coordinates :initarg :coordinates :accessor coordinates)
   (faces :initarg :faces :accessor faces)
   (parts :initarg :parts :accessor parts)))

(defun load-wf-object (filename)
  (with-open-file (in (merge-pathnames filename *data-directory*) :direction :input)
    (let ((coordinates (make-array 0 :adjustable t :fill-pointer t :element-type 'single-float))
          (faces (make-array 0 :adjustable t :fill-pointer t :element-type 'fixnum))
          (parts (make-hash-table))
          (part-start 0)
          (part-end 0)
          (part-name nil))
      (flet ((sexp-stream (string)
               (make-concatenated-stream
                (make-string-input-stream "(")
                (make-string-input-stream string)
                (make-string-input-stream ")"))))
        (loop for line = (read-line in nil nil)
              while line do
              (let ((line (string-trim '(#\Space #\Tab #\Return) line)))
                (cond ((emptyp line))
                      ((starts-with #\# line))
                      (t (let ((sexp (read (sexp-stream line))))
                           (case (car sexp)
                             (v (dolist (x (cdr sexp))
                                  (vector-push-extend x coordinates)))
                             (f (dolist (x (cdr sexp))
                                  (vector-push-extend (1- x) faces))
                                (incf part-end))
                             (o (cond ((null part-name)
                                       (setf part-name (cadr sexp)))
                                      (t
                                       (setf (gethash part-name parts)
                                             (list part-start part-end))
                                       (setf part-name (cadr sexp))
                                       (setf part-start part-end))))
                             (g)
                             (t (warn "Unexpected first element: ~S" (car sexp))))))))))
      (when part-name
        (setf (gethash part-name parts)
              (list part-start part-end)))
      (make-instance 'wf-object :coordinates coordinates :faces faces :parts parts))))

(defun wf-part-names (wf-object)
  (hash-table-keys (parts wf-object)))

(defun wf-draw (wf-object)
  (gl:with-primitive :triangles
    (let ((coords (coordinates wf-object))
          (faces (faces wf-object)))
      (loop for face across faces
            do (gl:vertex (aref coords (+ 0 (* 3 face)))
                          (- (aref coords (+ 2 (* 3 face))))
                          (aref coords (+ 1 (* 3 face))))))))

(defun wf-draw-part (part-name wf-object)
  (gl:with-primitive :triangles
    (let ((coords (coordinates wf-object))
          (faces (faces wf-object)))
      (destructuring-bind (start end)
          (gethash part-name (parts wf-object))
        (loop for i from (* 3 start) below (* end 3)
              for face = (aref faces i)
              do (gl:vertex (aref coords (+ 0 (* 3 face)))
                            (- (aref coords (+ 2 (* 3 face))))
                            (aref coords (+ 1 (* 3 face)))))))))

(defparameter *wf-object-repository* (make-hash-table))

(defun register-wf-object (name filename)
  (setf (gethash name *wf-object-repository*) (load-wf-object filename)))

(defun find-wf-object (name)
  (or (gethash name *wf-object-repository*)
      (error "Can't find Wavefront object ~S." name)))


;;;; Collision detection

(defclass collidable-object ()
  ())

(defgeneric collide-p (a b))

(defmethod collide-p :around (a b)
  (or (eql a b)
      (call-next-method)))

(defclass circle-collidable-object ()
  ((collision-radius :initarg :collision-radius :accessor collision-radius)
   (pos :initarg :pos :accessor pos)))

(defun close-enough-p (pa ra pb rb)
  (< (vec-distance-sq pa pb) (square (+ ra rb))))

(defmethod collide-p ((a circle-collidable-object)
                      (b circle-collidable-object))
  (close-enough-p (pos a) (collision-radius a)
                  (pos b) (collision-radius b)))


;;;; Game object protocol

(defclass pickable-object (collidable-object)
  ())

(defclass draggable-object (pickable-object)
  ())

(defclass selectable-object (pickable-object)
  ())

(defclass clickable-object (pickable-object)
  ())

(defgeneric update (object)
  (:method (object)
    (declare (ignore object))))

(defgeneric render (object))

(defgeneric select (object op pos)
  (:method ((object null) op pos)
    (declare (ignore op pos))))


;;;; Game world

(defparameter *half-world-dimensions* (vec 100.0 100.0))

(defvar *world*)
(defvar *tick*)

(defclass world ()
  ((objects-to-delete :initform '() :accessor objects-to-delete)
   (objects :initform (make-array 7 :initial-element '()) :accessor objects)
   (tick :initform nil :accessor tick)))

(defun make-world ()
  (make-instance 'world))

(defun add-object (object &optional (world *world*))
  (push object (aref (objects world) (object-list-index object))))

(defun object-list-index (object)
  (typecase object
    (message 6)
    (tower-control 5)
    (player 4)
    (projectile 3)
    (enemy 2)
    (tower 1)
    (t 0)))

(defun remove-object (object &optional (world *world*))
  (push object (objects-to-delete world)))

(defun expunge-objects (&optional (world *world*))
  (dolist (object (objects-to-delete world))
    (deletef (aref (objects world) (object-list-index object))
             object :count 1))
  (setf (objects-to-delete world) '()))

(defun map-objects (function world order type)
  (unless (type= type 'nil)
    (flet ((maybe-call-function (object)
             (when (and (typep object type)
                        (not (member object (objects-to-delete world))))
               (funcall function object))))
      (ecase order
        ((:render :update)
         (loop for list across (objects world) do
               (mapc #'maybe-call-function list)))
        ((:hit-test)
         (loop for i from (1- (length (objects world))) downto 0 do
               (mapc #'maybe-call-function (aref (objects world) i))))))))

(defmacro do-objects ((object-var &key (world '*world*) (order :hit-test) (type t) collecting) &body forms)
  (if collecting
      (with-gensyms (collection)
        `(let ((,collection '()))
           (flet ((collect (x) (push x ,collection)))
             (block nil
               (map-objects (lambda (,object-var) ,@forms) ,world ,order ,type)))
           ,collection))
      `(block nil
         (map-objects (lambda (,object-var) ,@forms) ,world ,order ,type))))

(defmethod update ((w world))
  (let ((*world* w)
        (*tick* (tick w)))
    (do-objects (object :order :update)
      (update object))
    (expunge-objects)))

(defmethod render ((w world))
  (let ((*world* w))
    (do-objects (object :order :render)
      (render object)
      (when (typep object *draw-collision-circle-for-type*)
        (gl:with-pushed-matrix
          (with-vec (x y (pos object))
            (gl:translate x y 0.0))
          (gl:color 1.0 0.0 0.0)
          (draw-circle (collision-radius object)))))))

(defun player (&optional (world *world*))
  (first (aref (objects world) 4)))

(defun tower-control (&optional (world *world*))
  (first (aref (objects world) 5)))


;;;; Game window

(defclass mouse (circle-collidable-object)
  ((selection :initform nil :accessor selection))
  (:default-initargs :pos (vec 0.0 0.0) :collision-radius 2))

(defun pick-object (mouse)
  (do-objects (object :type 'pickable-object)
    (when (collide-p object mouse)
      (return-from pick-object object))))

(defclass game-window (glut:window)
  ((world :accessor world)
   (world-generator :initarg :world-generator :accessor world-generator)
   (world-index :initform 0 :accessor world-index)
   (time-to-next-tick :initform nil :accessor time-to-next-tick)
   (mouse :initform (make-instance 'mouse) :accessor mouse))
  (:default-initargs
   :name 'towers
   :width 800 :height 800
   :title "Towers"
   :mode '(:double :rgb)))

(defmethod initialize-instance :after ((w game-window) &rest initargs)
  (declare (ignore initargs))
  (generate-world w))

(defun find-game-window ()
  (glut:find-window 'towers))

(defun next-world (&optional (w (find-game-window)))
  (incf (world-index w))
  (generate-world w))

(defun generate-world (&optional (w (find-game-window)))
  (setf (world w) (funcall (world-generator w) (world-index w))))

(defmethod tick ((w game-window))
  (tick (world w)))

(defmethod (setf tick) (new-value (w game-window))
  (setf (tick (world w)) new-value))

(defmethod glut:display-window :before ((w game-window))
  (gl:clear-color 0 0 0 0)
  (gl:shade-model :flat)
  (gl:disable :depth-test)
  (gl:enable :blend)
  (gl:blend-func :src-alpha :one-minus-src-alpha))

(defmethod glut:display ((w game-window))
  (gl:load-identity)
  (gl:clear-color 0 0 0 0)
  (gl:clear :color-buffer)
  (gl:translate .375 .375 0.0)
  (render (world w))
  (glut:swap-buffers))

(defmethod glut:reshape ((w game-window) width height)
  (gl:viewport 0 0 width height)
  (gl:matrix-mode :projection)
  (gl:load-identity)
  (with-vec (x y *half-world-dimensions*)
    (gl:ortho (- x) x (- y) y 0 1))
  (gl:matrix-mode :modelview))

(defmethod glut:keyboard ((w game-window) key x y)
  (declare (ignore x y))
  (case key
    (#\Esc (glut:destroy-current-window))))

(defmethod glut:motion ((w game-window) x y)
  (let ((*world* (world w)))
    (multiple-value-bind (x y) (glu:un-project x y 0.0)
      (vec-assign (pos (mouse w)) x (- y)))
    (select (selection (mouse w)) :move (pos (mouse w)))))

(defgeneric left-button (state mouse selected-object picked-object)
  (:method (state mouse selected-object picked-object)
    (declare (ignore state mouse selected-object picked-object))))

(defmethod glut:mouse ((w game-window) button state x y)
  (glut:motion w x y)
  (let ((*world* (world w)))
    (case button
      (:left-button
       (let ((m (mouse w)))
         (left-button state m (selection m) (pick-object m)))))))

(defun obtain-object (object mouse)
  (when (selection mouse)
    (release-object mouse))
  (setf (selection mouse) object)
  (select (selection mouse) :obtain (pos mouse)))

(defun release-object (mouse)
  (when (selection mouse)
    (select (selection mouse) :release (pos mouse))
    (setf (selection mouse) nil)))

(defmethod left-button ((state (eql :down)) mouse (selected-object selectable-object) (picked-object null))
  (release-object mouse))

(defmethod left-button ((state (eql :down)) mouse selected-object (picked-object selectable-object))
  (declare (ignore selected-object))
  (obtain-object picked-object mouse))

(defmethod left-button ((state (eql :down)) mouse selected-object (picked-object draggable-object))
  (declare (ignore selected-object))
  (obtain-object picked-object mouse))

(defmethod left-button ((state (eql :up)) mouse (selected-object draggable-object) picked-object)
  (declare (ignore picked-object))
  (release-object mouse))

(defmethod left-button ((state (eql :down)) mouse selected-object (picked-object clickable-object))
  (declare (ignore selected-object))
  (select picked-object :obtain (pos mouse)))

(defmethod left-button ((state (eql :up)) mouse selected-object (picked-object clickable-object))
  (declare (ignore selected-object))
  (select picked-object :release (pos mouse)))

(defmethod glut:idle ((w game-window))
  (let ((now (glut:get :elapsed-time)))
    (when (null (tick w))
      (setf (tick w) -1)
      (setf (time-to-next-tick w) now))
    (when (>= now (time-to-next-tick w))
      (incf (tick w))
      (setf (time-to-next-tick w) (+ now *tick-duration*))
      (update (world w))
      (glut:post-redisplay))))

(defun display-text (x y object &rest format-args)
  (let ((string (if (stringp object)
                    (apply #'format nil object format-args)
                    (princ-to-string object))))
    (gl:with-pushed-matrix
      (gl:load-identity)
      (gl:raster-pos x y)
      (glut:bitmap-string glut:+bitmap-8-by-13+ string))))


;;;; Game

(defun game ()
  (glut:display-window
   (make-instance
    'game-window
    :world-generator 
    (let ((levels #(level-1 level-2 level-random1 level-random2 level-random3 level-random4 
                    level-random5)))
      (lambda (index)
        (make-level (aref levels (mod index (length levels)))))))))

(defun randomgame ()
  (glut:display-window
   (make-instance
    'game-window
    :world-generator 
    (let ((levels #(level-random1 level-random2 level-random3 level-random4 
                    level-random5)))
      (lambda (index)
        (make-level (aref levels (mod index (length levels)))))))))



;;;; Player

(defclass player ()
  ((cash :initarg :cash :accessor cash)))

(defmethod render ((player player))
  (gl:with-pushed-matrix
    (gl:color 1.0 1.0 1.0)
    (display-text -90.0 -80.0 (cash player))))

(defun try-buy (tower &optional (player (player)))
  (when (>= (cash player) (buy-price tower))
    (decf (cash player) (buy-price tower))
    (incf (level tower))
    (add-object tower)))

(defun try-upgrade (tower &optional (player (player)))
  (when (and (< (level tower) (max-level tower))
             (>= (cash player) (buy-price tower)))
    (decf (cash player) (buy-price tower))
    (incf (level tower))))

(defun sell (tower &optional (player (player)))
  (incf (cash player) (sell-price tower))
  (setf (tower (tower-control)) nil)
  (remove-object tower))


;;;; Tower control

(defclass tower-control (clickable-object circle-collidable-object)
  ((tower :initarg :tower :accessor tower))
  (:default-initargs :tower nil :collision-radius 16 :pos (vec 62.0 -82.0)))

(defmethod render ((control tower-control))
  (when-let (tower (tower control))
    (gl:with-pushed-matrix
      (gl:color 0.2 0.5 1.0)
      (display-text 50.0 -75.0 (type-of tower))
      (display-text 50.0 -80.0 "Level ~D" (level tower))
      (when (< (level tower) (max-level tower))
        (display-text 50.0 -85.0 "Upgrade (~D)" (buy-price tower)))
      (display-text 50.0 -90.0 "Sell (~D)" (sell-price tower)))))

(defmethod select ((control tower-control) op pos)
  (ecase op
    (:obtain
     (when-let (tower (tower control))
       (with-vec (x y pos)
         (cond ((and (>= x 50.0) (>= y -86.0) (<= y -81.0))
                (try-upgrade tower))
               ((and (>= x 50.0) (>= y -91.0) (<= y -86.0))
                (sell tower))))))
    (:release)
    (:move)))


;;;; Grid

(defclass grid ()
  ())

(defmethod render ((grid grid))
  (gl:with-pushed-matrix
    (gl:color 0.2 0.2 0.2)
    (gl:translate -100.0 100.0 0.0)
    (gl:scale 1 -1 1)
    (gl:with-primitive :lines
      (dotimes (y 18)
        (gl:vertex 0.0 (* y 10.0))
        (gl:vertex 200.0 (* y 10.0)))
      (dotimes (x 20)
        (gl:vertex (* x 10.0) 0.0)
        (gl:vertex (* x 10.0) 170.0)))))


;;;; Path

(defclass path (collidable-object)
  ((vertices :initarg :vertices :accessor vertices)))

(defmethod initialize-instance :after ((path path) &rest initargs &key spline &allow-other-keys)
  (declare (ignore initargs))
  (when spline
    (setf (vertices path) (compile-path spline))))

(defmethod render ((path path))
  (gl:color 0.0 0.0 0.6)
  (gl:with-primitive :line-strip
    (loop for v across (vertices path) do
          (with-vec (x y v)
            (gl:vertex x y)))))

(defun compile-path (spline)
  (coerce
   (loop for (ax ay bx by cx cy dx dy) on spline by #'cddddddr
         when (and ax ay bx by cx cy dx dy)
         nconc (loop for (am bm cm dm) in (collect-results #'call-with-curve-multipliers)
                     collect (vec (+ (* am ax) (* bm bx) (* cm cx) (* dm dx))
                                  (+ (* am ay) (* bm by) (* cm cy) (* dm dy)))))
   'vector))

(defparameter *path-collision-radius* 3)

(defmethod collide-p ((a path) (b path))
  (some (lambda (va)
          (some (lambda (vb)
                  (close-enough-p va *path-collision-radius*
                                  vb *path-collision-radius*))
                (vertices b)))
        (vertices a)))

(defmethod collide-p ((a path) (b circle-collidable-object))
  (collide-p b a))

(defmethod collide-p ((a circle-collidable-object) (b path))
  (some (lambda (v)
          (close-enough-p (pos a) (collision-radius a)
                          v *path-collision-radius*))
        (vertices b)))


;;;; Message

(defclass message (clickable-object)
  ((pos :initarg :pos :accessor pos)
   (color :initarg :color :accessor color)
   (text :initarg :text :accessor text)
   (action :initarg :action :accessor action))
  (:default-initargs :action #'nothing))

(defmethod render ((m message))
  (gl:with-pushed-matrix
    (apply #'gl:color (color m))
    (with-vec (x y (pos m))
      (display-text x y "~A" (text m)))))

(defmethod collide-p ((message message) (mouse mouse))
  t)

(defmethod collide-p ((mouse mouse) (message message))
  t)

(defmethod collide-p ((message message) object)
  (declare (ignore object))
  nil)

(defmethod collide-p (object (message message))
  (declare (ignore object))
  nil)

(defmethod select ((m message) op pos)
  (declare (ignore pos))
  (ecase op
    (:obtain
     (remove-object m)
     (funcall (action m)))
    (:release)
    (:move)))


;;;; Homebase

(register-wf-object 'homebase "homebase.obj")

(defclass homebase (circle-collidable-object)
  ((lives :initarg :lives :accessor lives)
   (angle :initform 0.0 :accessor angle))
  (:default-initargs :collision-radius 8))

(defmethod update ((hb homebase))
  (incf (angle hb) 2))

(defmethod render ((hb homebase))
  (gl:color 0.6 0.2 0.8)
  (gl:with-pushed-matrix
    (with-vec (x y (pos hb))
      (gl:translate x y 0.0)
      (gl:scale 1.5 1.5 1.0)
      (gl:polygon-mode :front-and-back :line)
      (gl:rotate (angle hb) 0.0 0.0 1.0)
      (wf-draw (find-wf-object 'homebase))
      (gl:polygon-mode :front-and-back :fill)
      (display-text (- x 0.5) (- y 0.5) (max 0 (lives hb))))))


;;;; Towers

(defclass tower (selectable-object circle-collidable-object)
  ((level :initarg :level :accessor level)
   (factory :initarg :factory :accessor tower-factory))
  (:default-initargs :level 0))

(defgeneric try-fire (tower tick))
(defgeneric tower-projectile (tower))
(defgeneric fire-rate (tower))

(defgeneric buy-price (object))
(defgeneric sell-price (object))
(defgeneric max-level (object))

(defmethod buy-price ((tower tower))
  (aref (buy-prices (tower-factory tower)) (level tower)))

(defmethod sell-price ((tower tower))
  (aref (sell-prices (tower-factory tower)) (level tower)))

(defmethod max-level ((tower tower))
  (length (buy-prices (tower-factory tower))))

(defclass shooting-tower-mixin ()
  ((last-shot-tick :initform nil :accessor last-shot-tick)
   (base-fire-rate :initarg :base-fire-rate :accessor base-fire-rate)
   (detection-radius :initarg :detection-radius :accessor detection-radius)
   (draw-detection-circle :initarg :draw-detection-circle :accessor draw-detection-circle-p)
   (detection-circle-color :initform :red :accessor detection-circle-color))
  (:default-initargs :draw-detection-circle nil))

(defmethod fire-rate ((tower shooting-tower-mixin))
  (* (base-fire-rate tower) (level tower)))

(defmethod try-fire ((tower shooting-tower-mixin) tick)
  (let ((last-shot-tick (last-shot-tick tower)))
    (when (or (null last-shot-tick)
              (>= (- tick last-shot-tick) (floor *frames-per-second* (fire-rate tower))))
      (add-object (tower-projectile tower))
      (setf (last-shot-tick tower) tick))))

(defmethod render :after ((tower shooting-tower-mixin))
  (when (draw-detection-circle-p tower)
    (gl:with-pushed-matrix
      (with-vec (x y (pos tower))
        (gl:translate x y 0.0))
      (gl:color 0.0 1.0 1.0)
      (draw-circle (detection-radius tower))
      (ecase (detection-circle-color tower)
        (:red (gl:color 1.0 0.0 0.0 0.2))
        (:green (gl:color 0.0 1.0 0.0 0.2)))
      (draw-circle (detection-radius tower) 30 t))))

(register-wf-object 'blaster-tower "blaster.obj")

(defclass blaster-tower (tower shooting-tower-mixin)
  ((angle :initform 0.0 :accessor angle)
   (projectile-speed :initarg :projectile-speed :accessor projectile-speed))
  (:default-initargs
   :base-fire-rate 2
    :collision-radius 5
    :detection-radius 20
    :projectile-speed 2.0))

(defmethod update ((tower blaster-tower))
  (let ((enemies (detect-enemies tower)))
    (when enemies
      (when (some (lambda (enemy) (good-to-fire-p enemy tower)) enemies)
        (try-fire tower *tick*))
      (aim tower (best-element enemies :key (lambda (enemy) (target-angle enemy tower)))))))

(defun detect-enemies (tower)
  (do-objects (enemy :type 'enemy :collecting t)
    (when (close-enough-p (pos enemy) (collision-radius enemy)
                          (pos tower) (detection-radius tower))
      (collect enemy))))

(defgeneric projectile-initial-position (tower))
(defgeneric projectile-initial-velocity (tower))

(defun target-angle (enemy tower)
  (let ((pe (pos enemy))
        (ve (vel enemy))
        (pp (projectile-initial-position tower))
        (vp (projectile-initial-velocity tower)))
    (let* ((tc (/ (vec-distance pe pp) (vec-distance vp ve)))
           (pe-prime (vec+= (vec* ve tc) pe)))
      (normalize-deg (+ 270.0 (vec-angle (vec- pe-prime (pos tower))))))))

(defun good-to-fire-p (enemy tower)
  (let ((aim-angle (angle tower))
        (target-angle (target-angle enemy tower)))
    (< (abs (- aim-angle target-angle)) 4.0)))

(defun aim (tower enemy)
  (let* ((aim-angle (angle tower))
         (target-angle (target-angle enemy tower))
         (diff (- target-angle aim-angle)))
    (when (> diff 180.0) (decf diff 360.0))
    (when (< diff -180.0) (incf diff 360.0))
    (setf (angle tower)
          (normalize-deg (+ (angle tower)
                            (max -10.0 (min diff 10.0)))))))

(defmethod render ((tower blaster-tower))
  (let ((wf-object (find-wf-object 'blaster-tower)))
    (gl:with-pushed-matrix
      (with-vec (x y (pos tower))
        (gl:translate x y 0.0))
      (gl:color 0.0 1.0 0.0)
      (gl:scale 1.5 1.5 1.0)
      (gl:polygon-mode :front-and-back :line)
      (wf-draw-part 'blaster wf-object)
      (wf-draw-part 'inner-base wf-object)
      (gl:rotate (angle tower) 0.0 0.0 1.0)
      (wf-draw-part 'cannon wf-object)
      (gl:polygon-mode :front-and-back :fill))))

(defmethod select ((tower blaster-tower) op pos)
  (declare (ignore pos))
  (ecase op
    (:obtain
     (setf (draw-detection-circle-p tower) t)
     (setf (tower (tower-control)) tower))
    (:release
     (setf (tower (tower-control)) nil)
     (setf (draw-detection-circle-p tower) nil))
    (:move)))

(defclass projectile (circle-collidable-object)
  ((vel :initarg :vel :accessor vel)))

(defgeneric maybe-projectile-hit (projectile))

(defmethod update ((proj projectile))
  (vec+= (pos proj) (vel proj))
  (unless (vec-contains *half-world-dimensions* (pos proj))
    (remove-object proj)
    (return-from update))
  (maybe-projectile-hit proj))

(defclass blaster-projectile (projectile)
  ((damage :initarg :damage :accessor damage))
  (:default-initargs :collision-radius 0.5))

(defmethod projectile-initial-position ((tower blaster-tower))
  (vec+= (vel-vec 4.0 (- (angle tower))) (pos tower)))

(defmethod projectile-initial-velocity ((tower blaster-tower))
  (vel-vec (projectile-speed tower) (- (angle tower))))

(defmethod tower-projectile ((tower blaster-tower))
  (make-instance 'blaster-projectile
                 :pos (projectile-initial-position tower)
                 :vel (projectile-initial-velocity tower)
                 :damage 1))

(defmethod render ((proj blaster-projectile))
  (gl:with-pushed-matrix
    (with-vec (x y (pos proj))
      (gl:translate x y 0.0))
    (gl:color 0.0 1.0 0.0)
    (draw-circle 0.6)))

(defmethod maybe-projectile-hit ((proj blaster-projectile))
  (let ((hit nil))
    (do-objects (enemy :type 'enemy)
      (when (collide-p proj enemy)
        (setf hit t)
        (when (<= (decf (hit-points enemy) (damage proj)) 0)
          (enemy-kill enemy))))
    (when hit
      (remove-object proj))))

(defun enemy-kill (enemy)
  (incf (cash (player)) (cash-reward enemy))
  (add-object (make-instance 'explosion
                             :number-of-particles 100
                             :color (explosion-color enemy)
                             :center (pos enemy)))
  (enemy-die enemy))

(defclass tower-factory (draggable-object circle-collidable-object)
  ((buy-prices :initarg :buy-prices :accessor buy-prices)
   (sell-prices :initarg :sell-prices :accessor sell-prices)
   (kind :initarg :kind :accessor kind)
   (prototype :accessor prototype)
   (new-tower :initform nil :accessor new-tower)))

(defmethod initialize-instance :after ((factory tower-factory) &rest initargs)
  (declare (ignore initargs))
  (setf (prototype factory)
        (make-instance (kind factory) :pos (pos factory)))
  (setf (collision-radius factory)
        (collision-radius (prototype factory))))

(defmethod render ((factory tower-factory))
  (render (prototype factory))
  (when (new-tower factory)
    (render (new-tower factory)))
  (with-vec (x y (pos factory))
    (gl:color 1.0 1.0 1.0)
    (display-text (- x 0.5) (- y 10.0) (aref (buy-prices factory) 0))))

(defmethod select ((factory tower-factory) op pos)
  (with-slots (new-tower) factory
    (flet ((can-place-here-p ()
             (do-objects (object :type 'collidable-object)
               (when (collide-p new-tower object)
                 (return-from can-place-here-p nil)))
             t))
      (ecase op
        (:obtain
         (setf new-tower
               (make-instance (kind factory)
                              :pos (copy-vec pos)
                              :draw-detection-circle t
                              :factory factory)))
        (:release
         (when (can-place-here-p)
           (try-buy new-tower)
           (setf (draw-detection-circle-p new-tower) nil))
         (setf new-tower nil))
        (:move
         (when new-tower
           (vec-assign (pos new-tower) (x pos) (y pos))
           (setf (detection-circle-color new-tower)
                 (if (can-place-here-p) :green :red))))))))
                             

;;;; Enemies

(defclass enemy (circle-collidable-object)
  ((spd :initarg :speed :accessor spd)
   (path :initarg :path :accessor path)
   (next-pos-idx :initform 1 :accessor next-pos-idx)
   (hit-points :initarg :hit-points :accessor hit-points)
   (max-hit-points :initarg :hit-points :accessor max-hit-points)
   (cash-reward :initarg :cash-reward :accessor cash-reward)
   (vel :initform (vec 0.0 0.0) :accessor vel)
   (explosion-color :initarg :explosion-color :accessor explosion-color)))

(defmethod update ((e enemy))
  ;; Check collision with homebase
  (do-objects (hb :type 'homebase)
    (when (collide-p e hb)
      (enemy-die e)
      (when (= (decf (lives hb)) 0)
        (game-over))
      (return-from update)))
  ;; Compute position and velocity
  (let* ((pos (pos e))
         (vertices (vertices (path e)))
         (next-pos (aref vertices (next-pos-idx e))))
    (when (vec=~ pos next-pos (spd e))
      (incf (next-pos-idx e))
      (when (= (next-pos-idx e) (length vertices))
        ;; This shouldn't happen, as we're supposed to crash into
        ;; homebase before reaching the endpoint
        (enemy-die e)
        (return-from update))
      (setf next-pos (aref vertices (next-pos-idx e))))
    (setf (vel e) (vel-vec (spd e) (vec- next-pos pos)))
    (vec+= pos (vel e))))

(defmethod render :after ((e enemy))
  (gl:with-pushed-matrix
    (with-vec (x y (pos e))
      (gl:translate (- x 2.0) y 0.0))
    (let ((vs '((0.0 2.0) (4.0 2.0) (4.0 3.0) (0.0 3.0))))
      (gl:with-pushed-matrix
        (gl:scale (float (/ (hit-points e) (max-hit-points e))) 1.0 1.0)
        (gl:color 0.0 1.0 0.0 0.7)
        (gl:with-primitive :quads
          (loop for (x y) in vs do (gl:vertex x y))))
      (gl:color 1.0 1.0 1.0 0.5)
      (gl:with-primitive :line-loop
        (loop for (x y) in vs do (gl:vertex x y))))))

(defun enemy-die (enemy)
  (remove-object enemy)
  (maybe-win-level))

(defun maybe-win-level ()
  (flet ((no-win () (return-from maybe-win-level)))
    (do-objects (object :type '(or enemy wave homebase))
      (etypecase object
        ((or enemy wave) (no-win))
        (homebase (when (<= (lives object) 0) (no-win))))))
  (add-object
   (make-instance 'message
                  :pos (vec -8.0 0.0)
                  :color '(0.0 1.0 0.0)
                  :text "GOOD JOB"
                  :action #'next-world)))

(defun game-over ()
  (add-object
   (make-instance 'message
                  :pos (vec -8.0 0.0)
                  :color '(1.0 0.0 0.0)
                  :text "GAME OVER"
                  :action #'generate-world)))
                  
(defclass sqrewy (enemy)
  ((angle :initform 0 :accessor angle)
   (dir :initform '> :accessor dir))
  (:default-initargs :collision-radius 2 :explosion-color (list 0.0 0.5 0.5)))

(defmethod update :after ((sq sqrewy))
  (ecase (dir sq)
    (<
     (if (> (angle sq) 30)
         (setf (dir sq) '>)
         (incf (angle sq) 2)))
    (>
     (if (< (angle sq) -30)
         (setf (dir sq) '<)
         (decf (angle sq) 2)))))

(defmethod render ((sq sqrewy))
  (gl:with-pushed-matrix
    (with-vec (x y (pos sq))
      (gl:translate x y 0.0))
    (gl:rotate (angle sq) 0 0 1)
    (apply #'gl:color (explosion-color sq))
    (gl:with-primitive :line-loop
      (gl:vertex -2.0 -2.0)
      (gl:vertex +2.0 -2.0)
      (gl:vertex +2.0 +2.0)
      (gl:vertex -2.0 +2.0))))

(defclass sqarry (enemy)
  ((angle :initform 0.0 :accessor angle))
  (:default-initargs :collision-radius 2 :explosion-color (list 0.8 0.3 0.4)))

(defmethod update :after ((sq sqarry))
  (setf (angle sq) (mod+ (angle sq) -2.0 360.0)))

(defmethod render ((sq sqarry))
  (gl:with-pushed-matrix
    (with-vec (x y (pos sq))
      (gl:translate x y 0.0))
    (gl:rotate (angle sq) 0.0 0.0 1.0)
    (apply #'gl:color (explosion-color sq))
    (draw-star 2.0 5 2)))


(defclass sqroundy (enemy)
  ((angle :initform 0.0 :accessor angle))
  (:default-initargs :collision-radius 2 :explosion-color (list 0.9 0.9 0.9)))

(defmethod update :after ((sq sqroundy))
  (setf (angle sq) (mod+ (angle sq) -2.0 360.0)))

(defmethod render ((sq sqroundy))
  (gl:with-pushed-matrix
    (with-vec (x y (pos sq))
      (gl:translate x y 0.0))
    (gl:rotate (angle sq) 0.0 0.0 1.0)
    (apply #'gl:color (explosion-color sq))
    (draw-roundy sq)))

(defmethod draw-roundy ((sq sqroundy))
  (draw-circle 2))

(defclass sqpulser (sqroundy)
  ((sides :initform 6 :accessor sides))
  (:default-initargs :explosion-color (list 0.9 0.0 0.0)))

(defmethod draw-my-sides ((sq sqpulser) nsides &optional (radius 2) (filledp nil))
  (draw-sides nsides radius filledp))

(defmethod draw-roundy ((sq sqpulser))
  (progn
    (incf (sides sq))
    (if (> (sides sq) 32) (setf (sides sq) 6))
    (draw-my-sides sq (round (/ (sides sq) 2)) (collision-radius sq))))

(defun draw-sides (n &optional (radius 2) (filledp nil)) 
  (if (> n 2)
      (draw-circle radius n filledp)))

;;; a pulser that pulses pentagrams 
(defclass sqgrampulser (sqpulser)
  ((sides :initform 6 :accessor sides))
  (:default-initargs :explosion-color (list 0.97 0.97 0.97)))

(defmethod draw-my-sides ((sq sqgrampulser) nsides &optional (radius 2) (filledp nil))
  (draw-agram nsides radius filledp))


(defclass sngon (sqroundy)
  ((sides :initform 3 :accessor sides))
  (:default-initargs :explosion-color (list 0.9 0.1 0.7)))

(defmethod draw-roundy ((sq sngon))
    (draw-sides (sides sq) (collision-radius sq)))


(defclass sqpentagon  (sngon) ((sides :initform 5))
  (:default-initargs :explosion-color (list 0.6 0.6 0.6)))
(defclass sqhexagon   (sngon) ((sides :initform 6))
  (:default-initargs :explosion-color (list 0.6 0.3 0.6)))  
(defclass sqheptagon  (sngon) ((sides :initform 7))
  (:default-initargs :explosion-color (list 0.6 0.9 0.99)))
(defclass sqoctagon   (sngon) ((sides :initform 8))
  (:default-initargs :explosion-color (list 0.96 0.96 0.6)))
(defclass sqenneagon (sngon) ((sides :initform 9))
  (:default-initargs :explosion-color (list 0.1 0.9 0.6)))

(defclass snagram (sqroundy)
  ((points :initform 6 :accessor points))
  (:default-initargs :explosion-color (list 0.9 0.1 0.7)))

(defmethod draw-roundy ((sq snagram))
    (draw-agram (points sq) (collision-radius sq)))

(defclass sqpentagram  (snagram) ((points :initform 5))
  (:default-initargs :explosion-color (list 0.6 0.6 0.6)))

(defclass sqhexagram   (snagram) ((points :initform 6))
  (:default-initargs :explosion-color (list 0.6 0.3 0.6)))  

(defclass sqheptagram  (snagram) ((points :initform 7))
  (:default-initargs :explosion-color (list 0.6 0.9 0.99)))

(defclass sqoctagram   (snagram) ((points :initform 8))
  (:default-initargs :explosion-color (list 0.96 0.96 0.6)))

(defclass sqenneagram (snagram) ((points :initform 9))
  (:default-initargs :explosion-color (list 0.1 0.9 0.6)))



;;;; Waves

(defclass wave ()
  ((enemies :initarg :enemies :accessor enemies)
   (start-tick :initarg :start-tick :accessor start-tick)
   (wait-ticks :initarg :wait-ticks :accessor wait-ticks)
   (last-release-tick :initform nil :accessor last-release-tick)))

(defmethod update ((w wave))
  (let ((tick *tick*))
    (when (>= tick (start-tick w))
      (cond ((null (enemies w))
             (remove-object w))
            ((or (null (last-release-tick w))
                 (>= (- tick (last-release-tick w)) (wait-ticks w)))
             (release-an-enemy w)
             (setf (last-release-tick w) tick))))))

(defmethod render ((w wave)))  

(defun release-an-enemy (wave)
  (add-object (pop (enemies wave))))


;;;; Explosions

(defclass explosion ()
  ((particles :accessor particles)
   (color :initarg :color :accessor color)
   (center :initarg :center :accessor center)))

(defclass explosion-particle ()
  ((pos :initarg :pos :accessor pos)
   (vel :initarg :vel :accessor vel)
   (acc :initarg :acc :accessor acc)
   (ang :initarg :ang :accessor ang)
   (mul :initarg :mul :accessor mul)
   (nrg :initarg :nrg :accessor nrg)))

(defmethod initialize-instance :after ((e explosion) &rest initargs &key number-of-particles center &allow-other-keys)
  (declare (ignore initargs))
  (with-vec (cx cy center)
    (flet ((new-particle ()
             (let ((a (random 360.0))
                   (e (+ 50 (random 20)))
                   (v (random 1.0)))
               (make-instance 'explosion-particle
                              :pos (vec cx cy)
                              :vel (vel-vec v a)
                              :acc (vel-vec (random (/ v e)) (- 360.0 a))
                              :nrg e
                              :ang (random 360.0)
                              :mul (/ (- (random 2.0) 1.0) 3.0)))))
      (setf (particles e) (make-array number-of-particles))
      (map-into (particles e) #'new-particle))))

(defmethod update ((e explosion))
  (let ((dead 0))
    (flet ((update-particle (p)
             (cond ((plusp (nrg p))
                    (vec+= (pos p) (vel p))
                    (vec+= (vel p) (acc p))
                    (decf (nrg p))
                    (incf (ang p) (* (mul p) (nrg p))))
                   (t
                    (incf dead)))))
      (map nil #'update-particle (particles e)))
    (when (= dead (length (particles e)))
      (remove-object e))))

(defmethod render ((e explosion))
  (destructuring-bind (r g b) (color e)
    (flet ((render-particle (p)
             (when (plusp (nrg p))
               (gl:with-pushed-matrix
                 (with-vec (px py (pos p))
                   (gl:translate px py 0.0))
                 (gl:rotate (ang p) 0.0 0.0 1.0)
                 (gl:color r g b (/ (nrg p) 70.0))
                 (gl:with-primitive :line-loop
                   (gl:vertex -1.0 0.0)
                   (gl:vertex +1.0 0.0)
                   (gl:vertex  0.0 1.0))))))
      (map nil #'render-particle (particles e)))))


;;;; Levels

(defgeneric make-level (name))

(defmacro define-level (name &body objects)
  (labels ((object-name (object)
             (getf (cdr object) :named))
           (object-class-name (object)
             (car object))
           (object-initargs (object)
             (let ((list (copy-list (cdr object))))
               (remf list :named)
               list)))
    (let ((object-names (loop for object in objects
                              when (object-name object)
                              collect it)))
      `(defmethod make-level ((name (eql ',name)))
         (let ((world (make-instance 'world)) ,@object-names)
           ,@(loop for object in objects
                   for name = (object-name object)
                   for make = `(make-instance ',(object-class-name object) ,@(object-initargs object))
                   collect `(add-object ,(if name `(setf ,name ,make) make) world))
           world)))))

(define-level level-1
  (homebase :lives 2 :pos (vec -50.0 -50.0))
  (path :named path :spline '(0.0 100.0 10.0 10.0 -10.0 -10.0 -50.0 -50.0))
  (player :cash 10)
  (tower-control)
  (tower-factory :kind 'blaster-tower :pos (vec -60.0 -85.0)
                 :buy-prices #(5 5 7 10 15 20 30)
                 :sell-prices #(0 2 5 7 10 15 25 35))
  (wave :start-tick 100 :wait-ticks 50 :enemies
        (loop repeat 5 collecting
              (make-instance 'sqarry
                             :pos (vec 0.0 100.0)
                             :speed 0.4
                             :path path
                             :hit-points 5
                             :cash-reward 1)))
  (wave :start-tick 500 :wait-ticks 50 :enemies
        (loop repeat 6 collecting
              (make-instance 'sqrewy
                             :pos (vec 0.0 100.0)
                             :speed 0.6
                             :path path
                             :hit-points 10
                             :cash-reward 3)))
  (wave :start-tick 1000 :wait-ticks 40 :enemies
        (loop repeat 7 collecting
              (make-instance 'sqrewy
                             :pos (vec 0.0 100.0)
                             :speed 0.7
                             :path path
                             :hit-points 15
                             :cash-reward 5)))
  (grid))

(define-level level-2
  (homebase :lives 5 :pos (vec -57.375 -49.375))
  (path :named path :spline '(0.0 100.0 14.125 74.375 -44.625 69.125 -57.375
                              39.625 -67.125 1.875 -6.125 23.625 34.625
                              46.125 64.625 62.875 118.875 15.125 60.125
                              -36.375 13.125 -61.875 -32.875 -26.125 -57.375 -49.375))
  (player :cash 20)
  (tower-control)
  (tower-factory :kind 'blaster-tower :pos (vec -60.0 -85.0)
                 :buy-prices #(5 5 7 10 15 20 30)
                 :sell-prices #(0 2 5 7 10 15 25 35))
  (wave :start-tick 100 :wait-ticks 50 :enemies
        (loop repeat 10 collecting
              (make-instance 'sqrewy
                             :pos (vec 0.0 100.0)
                             :speed 0.5
                             :path path
                             :hit-points 10
                             :cash-reward 2)))
  (wave :start-tick 400 :wait-ticks 40 :enemies
        (loop repeat 5 collecting
              (make-instance 'sqrewy
                             :pos (vec 0.0 100.0)
                             :speed 0.6
                             :path path
                             :hit-points 15
                             :cash-reward 5)))
  (wave :start-tick 800 :wait-ticks 50 :enemies
        (loop repeat 10 collecting
              (make-instance 'sqarry
                             :pos (vec 0.0 100.0)
                             :speed 0.8
                             :path path
                             :hit-points 30
                             :cash-reward 10)))
  (wave :start-tick 1200 :wait-ticks 40 :enemies
        (loop repeat 10 collecting
              (make-instance 'sqroundy
                             :pos (vec 0.0 100.0)
                             :speed 0.9
                             :path path
                             :hit-points 30
                             :cash-reward 10)))
  (wave :start-tick 1500 :wait-ticks 60 :enemies
        (loop repeat 10 collecting
              (make-instance 'sqrewy
                             :pos (vec 0.0 100.0)
                             :speed 0.9
                             :path path
                             :hit-points 30
                             :cash-reward 10)))
  (wave :start-tick 2000 :wait-ticks 60 :enemies
        (loop repeat 10 collecting
              (make-instance 'sqrewy
                             :pos (vec 0.0 100.0)
                             :speed 1.0
                             :path path
                             :hit-points 30
                             :cash-reward 10)))
  (wave :start-tick 2500 :wait-ticks 60 :enemies
        (loop repeat 10 collecting
              (make-instance 'sqrewy
                             :pos (vec 0.0 100.0)
                             :speed 1.0
                             :path path
                             :hit-points 60
                             :cash-reward 10)))
  (wave :start-tick 3000 :wait-ticks 60 :enemies
        (loop repeat 10 collecting
              (make-instance 'sqrewy
                             :pos (vec 0.0 100.0)
                             :speed 2.0
                             :path path
                             :hit-points 60
                             :cash-reward 10)))
  (grid))

;; Sorry about this crap
; this fuctions tries to generate a tuple of the next position to place 
; the spline, it checks bounds.
(defun gsp-good-step (x y xstep ystep)
  (let ((nx (+ x (- (* 2 (random xstep)) xstep)))
        (ny (+ y (- (* 2 (random ystep)) ystep))))
    (if (or
         (> (abs nx) (x *half-world-dimensions*)) 
         (> (abs ny) (y *half-world-dimensions*)))
        (gsp-good-step x y xstep ystep)
        (list nx ny nx ny))))

; I couldn't figure out the loop macro enough to do this
; This executes random walk backwards (brownian motion) using tail recursion
(defun generate-spline-iterate (pts n l xstep ystep)
  (if (= n pts)
      l
      (generate-spline-iterate pts (+ n 1) (append (gsp-good-step (car l) (cadr l) xstep ystep) l) xstep ystep)))

;;; random walk
(defun generate-spline (endpos pts)
  (let* ((l (list 
             (x endpos) (y endpos) (x endpos) (y endpos)
             (x endpos) (y endpos) (x endpos) (y endpos)))
         (xstep (/ (x *half-world-dimensions*) 2.0))
         (ystep (/ (y *half-world-dimensions*) 2.0)))
    (generate-spline-iterate pts 1 l xstep ystep)))

;               (let ((enemies #('sqarry)))
;                 (aref enemies (random (length enemies)))))    

(defun choose-arr (l) (aref l (random (length l))))

; This functions generates waves of enemies 
(defun generate-waves (nwaves x y path) 
  (let* ((start-time 100)
         (inverse-speed 0.2))
    (labels (;(random-enemy-type () (nth enemies (random (length enemies))))
             (gen-wave (start-time inverse-speed nenemies hp cash)
                            `(wave :start-tick ,start-time :wait-ticks ,(+ 30 (random 100)) :enemies
                                  (loop repeat ,nenemies collecting
                                       (make-instance ', (choose-arr #(sqarry 
                                                                       sqroundy 
                                                                       sqrewy 
                                                                       sqpulser
                                                                       sqpentagon 
                                                                       sqhexagon  
                                                                       sqheptagon 
                                                                       sqoctagon  
                                                                       sqenneagon
                                                                       sqgrampulser
                                                                       sqpentagram
                                                                       sqhexagram 
                                                                       sqheptagram
                                                                       sqoctagram 
                                                                       sqenneagram))
                                                      :pos (vec ,x ,y)
                                                      :speed ,inverse-speed
                                                      :path path
                                                      :hit-points ,hp
                                                      :cash-reward ,cash))))
         ; this is done recursively because hp and cash rely on the last values
             (make-waves (nwaves start-time inverse-speed nememies hp cash)
               (if (= nwaves 0)
                   (list)
                   (cons 
                    (gen-wave start-time inverse-speed nememies hp cash)
                    (make-waves (- nwaves 1) 
                                (+ start-time 200 (random 500))
                                (* (+ 1.0 (* 0.6 (/ (random 100) 100.0))) inverse-speed)
                                (+ 5 (random 20))
                                (+ hp (random 10))
                                (+ cash (random (+ 1 cash))))))))
      (make-waves nwaves start-time inverse-speed 
                  (+ 5 (random 10)) 10 (+ 1 (random 2))))))

(defun generate-level (level-name)
  (let* ((hpos (vec (* -1.0 (random 60)) (random 50)))
         (spline (generate-spline hpos (+ 2 (random 30))))
         (tpos (vec -60.0 -85.0))
         ;; this is lame, because it is a macro I have to do all of this work
           (level-head `(define-level ,level-name
                            (homebase :lives 5 :pos (vec ,(x hpos) ,(y hpos)))
                          (path :named path :spline ',spline)
                          (player :cash 20)
                          (tower-control)
                          (tower-factory :kind 'blaster-tower :pos (vec ,(x tpos) ,(y tpos))
                                         :buy-prices #(5 5 7 10 15 20 30)
                                         :sell-prices #(0 2 5 7 10 15 25 35))))
         (waves (generate-waves (+ 5 (random 10)) (car spline) (cadr spline) spline))
         (final (append level-head waves `((grid)))))
    (progn
      (print final)
      (eval final))))

(generate-level 'level-random1)
(generate-level 'level-random2)
(generate-level 'level-random3)
(generate-level 'level-random4)
(generate-level 'level-random5)
         

Spline editor

(defclass spliner ()
  ((points :initform '() :accessor points)))

(defmethod render ((sp spliner))
  (gl:color 1.0 1.0 1.0)
  (let ((spline (loop for p in (points sp)
                      nconc (with-vec (x y (pos p)) (list x y)))))
    (let ((path (compile-path spline)))
      (when (not (emptyp path))
        (gl:with-primitive :line-strip
          (loop for v across path do
                (with-vec (x y v)
                  (gl:vertex x y))))))))

(defclass spline-point (draggable-object circle-collidable-object)
  ()
  (:default-initargs :collision-radius 2))

(defmethod render ((sp spline-point))
  (gl:color 1.0 1.0 1.0)
  (gl:with-pushed-matrix
    (with-vec (x y (pos sp))
      (gl:translate x y 0.0)
      (draw-circle 2))))

(defmethod select ((sp spline-point) op pos)
  (ecase op
    (:obtain)
    (:release)
    (:move (vec-assign (pos sp) (x pos) (y pos)))))

(define-level spline-editor
  (spliner)
  (grid))

(defclass spline-editor (game-window)
  ((mouse :initform (make-instance 'mouse) :accessor mouse)))

(defmethod glut:keyboard ((w spline-editor) key x y)
  (let ((*world* (world w)))
    (let ((mouse (mouse w))
          (spliner (do-objects (x :type 'spliner) (return x))))
      (multiple-value-bind (x y) (glu:un-project x y 0.0)
        (vec-assign (pos (mouse w)) x (- y)))
      (case key
        (#\a
         (let ((sp (make-instance 'spline-point :pos (copy-vec (pos mouse)))))
           (appendf (points spliner) (list sp))
           (add-object sp)))
        (#\d
         (when-let (sp (pick-object (mouse w)))
           (deletef (points spliner) sp)
           (remove-object sp)))
        (#\p
         (format t "(")
         (dolist (sp (points spliner))
           (with-vec (x y (pos sp))
             (format t " ~,3F ~,3F~%" x y)))
         (format t ")~%")
         (finish-output))
        (t (call-next-method))))))

(defun spline-editor ()
  (glut:display-window
   (make-instance 'spline-editor
                  :world-generator
                  (lambda (index)
                    (declare (ignore index))
                    (make-level 'spline-editor)))))

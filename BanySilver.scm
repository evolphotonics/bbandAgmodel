;;; Freesnell SCM Scheme code to calculate the theoretical normal reflectance of a 3-layer system corresponding to the Bicyclus anynana silver scale ultrastructure.
;;; Author: Vinodkumar Saranathan (https://github.com/evolphotonics, August 2021)


;;; load required files/libraries
(require 'edit-line)
(require 'FreeSnell)
(require 'databases)
(require 'database-interpolate)
(require 'eps-graph)
(require 'printf)


;;; define some parameters that we can override from the command line (cl), if need be
(define chitin 1.56)
(define air 1.0)
(define ul 0.64e-7)
(define airgap 1.42e-6)
(define ll 0.81e-7)
(define outfile "BanySilver.txt")


;;; code to handle command line arguments
(define (cline.script args)
  (cond ((= 4 (length args)) ;check if 4 arguments are passed to us
        (set! ul (string->number (list-ref args 0)))
        (set! airgap (string->number (list-ref args 1)))
        (set! ll (string->number (list-ref args 2)))
        (set! outfile (list-ref args 3))
        )
        (else  ;if not, throw an exception and exit gracefully
            (print "\n\nERROR: Incorrect number of arguments\n 
            Specify upper lamina, air gap and lower lamina thicknesses and output file name in that order, E.g.: /your/path/to/scm BanySilver.scm 0.64e-7 1.42e-6 0.81e-7 outfilename \n\n 
            Debug Info (Call):" *argv* "\n\n")
            (exit)
        )
  )
)


(cline.script (list-tail *argv* *optind*))


;;; main function
(define (BanySilver)
  (plot-response
   (output-data outfile) ;output as tab-delimited
   
   ;;; output plot
   ;;; (uncomment the next 3 lines to plot and save the reflectance as a PostScript file) 
   ;(title outfile outfile)
   ;(output-format 'ps)
   ;(font 'Helevetica 12)
   
   (samples 1200) ;;; no of points between 300 to 700 nm
   (wavelengths 0.3e-6 0.7e-6)

   ;(smooth 5e-9) ;;;NOT used

   ;;; incident angle is defined from normal
   ;;;reflection from top - R and bottom - B
   (incident 0 'R) ;use only this line for normal incidence, uncomment other lines to do angle-resolved reflectance predictions
;   (incident 10 'R)
;   (incident 20 'R)
;   (incident 30 'R)
;   (incident 40 'R)
;   (incident 50 'R)
;   (incident 60 'R)
;   (incident 70 'R)
;   (incident 80 'R)
;   (incident 90 'R)
    
    ;;; create color swatches with CIE illuminant D65
   (color-swatch 0 'R) ; 
;   (color-swatch 10 'R) 
;   (color-swatch 20 'R) 
;   (color-swatch 30 'R) 
;   (color-swatch 40 'R) 
;   (color-swatch 50 'R) 
;   (color-swatch 60 'R) 
;   (color-swatch 70 'R) 
;   (color-swatch 80 'R) 
;   (color-swatch 90 'R) 

   (range 0 1) ;;;y-axis limits

   ;;; define the thin-film/multi-layer stack	
   ;(stack-colors 0) ;;; defaults to black
   (optical-stack
    ;(nominal 1e-7) ;;;100 nm nominal thickness
    (substrate 1) ;;;air
    (layer chitin ul) ;;; upper lamina layer r.i. thickness in m
    (layer air airgap) ;;; layer r.i. thickness in m
    (layer chitin ll) ;;; lower lamina layer r.i. thickness in m
    (substrate 1) ;;;air
    )
  )
)

;;; invoke the main function to run
(BanySilver)

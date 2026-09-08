(defun c:SPOOLMAIN
  ( / flangeOD flangeThickness
      mandrelOD mandrelHeight actualMandrelHeight
      holeDia cableDia
      recessDepth capRecessDia capOffset
      flange mandrel mainPart hole channel
      cap capRecess capHole
      channelLength channelX channelY channelZ )

  ;; -----------------------------
  ;; GET DIMENSIONS
  ;; -----------------------------

  (setq flangeOD
        (getreal "\nEnter flange outside diameter: "))

  (setq flangeThickness
        (getreal "\nEnter flange thickness: "))

  (setq mandrelOD
        (getreal "\nEnter mandrel outside diameter: "))

  ;; This is the desired mandrel height
  ;; AFTER the cap is assembled
  (setq mandrelHeight
        (getreal "\nEnter desired mandrel height: "))

  (setq holeDia
        (getreal "\nEnter center hole diameter: "))

  (setq cableDia
        (getreal "\nEnter cable diameter: "))


  ;; -----------------------------
  ;; CALCULATE DERIVED DIMENSIONS
  ;; -----------------------------

  ;; Cap recess is half of cap thickness
  (setq recessDepth
        (/ flangeThickness 2.0))

  ;; Mandrel must extend into the cap recess,
  ;; so make the physical mandrel longer
  (setq actualMandrelHeight
        (+ mandrelHeight recessDepth))

  ;; Cap recess is 0.010 larger than mandrel
  (setq capRecessDia
        (+ mandrelOD 0.010))

  ;; Put cap to the right of the main piece
  (setq capOffset
        (+ flangeOD 0.5))


  ;; =========================================================
  ;; MAIN SPOOL PIECE
  ;; =========================================================


  ;; -----------------------------
  ;; CREATE FLANGE
  ;; -----------------------------

  (command "_.CYLINDER"
           "_non"
           '(0 0 0)
           "_D"
           flangeOD
           flangeThickness)

  (setq flange (entlast))


  ;; -----------------------------
  ;; CREATE MANDREL
  ;; -----------------------------

  (command "_.CYLINDER"
           "_non"
           (list 0 0 flangeThickness)
           "_D"
           mandrelOD
           actualMandrelHeight)

  (setq mandrel (entlast))


  ;; -----------------------------
  ;; UNION FLANGE + MANDREL
  ;; -----------------------------

  (command "_.UNION"
           flange
           mandrel
           "")

  (setq mainPart (entlast))


  ;; -----------------------------
  ;; CREATE CENTER HOLE CUTTER
  ;; -----------------------------

  (command "_.CYLINDER"
           "_non"
           (list 0 0 -0.1)
           "_D"
           holeDia
           (+ flangeThickness actualMandrelHeight 0.2))

  (setq hole (entlast))


  ;; -----------------------------
  ;; SUBTRACT CENTER HOLE
  ;; -----------------------------

  (command "_.SUBTRACT"
           mainPart
           ""
           hole
           "")


  ;; -----------------------------
  ;; CALCULATE CHANNEL GEOMETRY
  ;; -----------------------------

  ;; Make cutter slightly longer than flange
  (setq channelLength
        (+ flangeOD 0.2))

  ;; Start beyond left side of flange
  (setq channelX
        (- (/ channelLength 2.0)))

  ;; Channel begins tangent to mandrel
  (setq channelY
        (/ mandrelOD 2.0))

  ;; Cut downward by one cable diameter
  (setq channelZ
        (- flangeThickness cableDia))


  ;; -----------------------------
  ;; CREATE CHANNEL CUTTER
  ;; -----------------------------

  (command "_.BOX"

           "_non"
           (list channelX
                 channelY
                 channelZ)

           "_non"
           (list (/ channelLength 2.0)
                 (+ channelY cableDia)
                 channelZ)

           cableDia)

  (setq channel (entlast))


  ;; -----------------------------
  ;; SUBTRACT CHANNEL
  ;; -----------------------------

  (command "_.SUBTRACT"
           mainPart
           ""
           channel
           "")


  ;; =========================================================
  ;; CAP PIECE
  ;; =========================================================


  ;; -----------------------------
  ;; CREATE CAP
  ;; -----------------------------

  (command "_.CYLINDER"
           "_non"
           (list capOffset 0 0)
           "_D"
           flangeOD
           flangeThickness)

  (setq cap (entlast))


  ;; -----------------------------
  ;; CREATE RECESS CUTTER
  ;; -----------------------------

  ;; The top of the cap is at flangeThickness.
  ;; Start the cutter at:
  ;;
  ;; flangeThickness - recessDepth
  ;;
  ;; and cut upward through the top surface.

  (command "_.CYLINDER"
           "_non"
           (list capOffset
                 0
                 (- flangeThickness recessDepth))
           "_D"
           capRecessDia
           (+ recessDepth 0.1))

  (setq capRecess (entlast))


  ;; -----------------------------
  ;; SUBTRACT RECESS
  ;; -----------------------------

  (command "_.SUBTRACT"
           cap
           ""
           capRecess
           "")


  ;; -----------------------------
  ;; CREATE CAP CENTER HOLE
  ;; -----------------------------

  (command "_.CYLINDER"
           "_non"
           (list capOffset 0 -0.1)
           "_D"
           holeDia
           (+ flangeThickness 0.2))

  (setq capHole (entlast))


  ;; -----------------------------
  ;; SUBTRACT CAP CENTER HOLE
  ;; -----------------------------

  (command "_.SUBTRACT"
           cap
           ""
           capHole
           "")


  ;; -----------------------------
  ;; DONE
  ;; -----------------------------

  (princ "\nMain spool piece and cap created.")
  (princ)
)
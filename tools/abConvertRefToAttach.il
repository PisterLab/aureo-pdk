/* abConvertRefToAttach.il

Author     A.D.Beckett
Group      Custom IC (UK), Cadence Design Systems Ltd.
Language   SKILL
Date       Dec 15, 2010 
Modified   
By         

Convert a referenced technology library (or one with its own
tech database) into one that is attached to another library.

Bit cleaner than just removing the tech.db

Usage:

abConvertRefToAttach("libName" "techLibName")

***************************************************

SCCS Info: @(#) abConvertRefToAttach.il 03/13/17.14:30:48 1.1

*/

(defun abConvertRefToAttach (libName attachLibName "tt")
  (let (libId techId attachLibId attachTechId)
    (unless (setq libId (ddGetObj libName))
      (error "Could not access library %s\n" libName))
    (setq techId (techGetTechFile libId))
    (unless (equal (getq techId libName) libName)
      (error "Library is already attached to tech library %s\n"
             (getq techId libName)))
    (unless (setq attachLibId (ddGetObj attachLibName))
      (error "Could not access library %s\n" attachLibName))
    (setq attachTechId (techGetTechFile attachLibId))
    (techDeleteTechFile techId)
    (techBindTechFile
      libId (getq attachTechId libName) (getq attachTechId fileName))
    t
    )
)
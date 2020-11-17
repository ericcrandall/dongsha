
USETEXTLINKS = 1
STARTALLOPEN = 0
WRAPTEXT = 1
PRESERVESTATE = 0
HIGHLIGHT = 1
ICONPATH = 'file:///C:/Users/Eric/Desktop/WinArl35/'    //change if the gif's folder is a subfolder, for example: 'images/'

foldersTree = gFld("<i>ARLEQUIN RESULTS (Nplicata_dongsha.arp)</i>", "")
insDoc(foldersTree, gLnk("R", "Arlequin log file", "Arlequin_log.txt"))
	aux1 = insFld(foldersTree, gFld("Run of 17/11/20 at 11:31:45", "Nplicata_dongsha.xml#17_11_20at11_31_45"))
	insDoc(aux1, gLnk("R", "Settings", "Nplicata_dongsha.xml#17_11_20at11_31_45_run_information"))
		aux2 = insFld(aux1, gFld("Samples", ""))
		insDoc(aux2, gLnk("R", "Nplicata_Dongsha", "Nplicata_dongsha.xml#17_11_20at11_31_45_group0"))
		aux2 = insFld(aux1, gFld("Within-samples summary", ""))
		insDoc(aux2, gLnk("R", "Neutrality tests", "Nplicata_dongsha.xml#17_11_20at11_31_45_comp_sum_neutests"))

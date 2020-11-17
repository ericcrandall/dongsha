
USETEXTLINKS = 1
STARTALLOPEN = 0
WRAPTEXT = 1
PRESERVESTATE = 0
HIGHLIGHT = 1
ICONPATH = 'file:///C:/Users/Eric/Desktop/WinArl35/'    //change if the gif's folder is a subfolder, for example: 'images/'

foldersTree = gFld("<i>ARLEQUIN RESULTS (Cvroliki_dongsha.arp)</i>", "")
insDoc(foldersTree, gLnk("R", "Arlequin log file", "Arlequin_log.txt"))
	aux1 = insFld(foldersTree, gFld("Run of 17/11/20 at 14:12:30", "Cvroliki_dongsha.xml#17_11_20at14_12_30"))
	insDoc(aux1, gLnk("R", "Settings", "Cvroliki_dongsha.xml#17_11_20at14_12_30_run_information"))
		aux2 = insFld(aux1, gFld("Samples", ""))
		insDoc(aux2, gLnk("R", "Cvroliki_Dongsha", "Cvroliki_dongsha.xml#17_11_20at14_12_30_group0"))
		aux2 = insFld(aux1, gFld("Within-samples summary", ""))
		insDoc(aux2, gLnk("R", "Neutrality tests", "Cvroliki_dongsha.xml#17_11_20at14_12_30_comp_sum_neutests"))

Formats de documents XML : Projet de XML : Cartes des lignes du métro

Commandes qui doivent être exécutées dans l'invite de commande afin d'utiliser les fichiers de projet :

1. extracteur.py (l'exécution du programme prend du temps)
-- La commande :
python extracteur.py base_ratp.csv

-- Exemple :
PS C:\Users\lenny\git\projet-xml> python extracteur.py
Veuillez transmettre au programme un chemin d acces au fichier csv en tant que parametre via la ligne de commande.
PS C:\Users\lenny\git\projet-xml> python extracteur.py base_ratp.csv
Le logiciel va maintenant convertir le fichier csv en un fichier xml nommé fichier_xml.xml. Le processus peut prendre un temps relativement long...


2. DTD : metro.dtd
Le fichier xsd (Schéma XML) est conçu pour vérifier que la structure du fichier xml est correcte et conforme au format spécifié.
A cette occasion, nous avons créé, bien qu'il n'y avaitaucune obligation de le faire dans le cadre du projet, un fichier DTD ayant le même objectif. 
Cependant, l'utilisation du fichier xsd est bien sûr à privilégier car il permet un meilleur contrôle du contenu du fichier xml.

-- A ajouter au document xml (apres la 1er ligne) : <!DOCTYPE ratp SYSTEM "metro.dtd">
-- La commande : xmllint -dtdvalid metro.dtd fichier_xml.xml
 
3. Schéma XML : metro.xsd
-- La commande : xmllint --schema metro.xsd fichier_xml.xml
Le Fichier est valide si cette commande affiche : "fichier_xml.xml validates".

4. XSLT : stylesheet.xsl 
- La modification du numéro de la ligne de métro se fait en modifiant la valeur de la variable suivante dans le fichier :

	<!-- Une variable qui a pour but de stocker le numéro de ligne dont on veut afficher le plan -->
	<xsl:variable name="numero-ligne" as="xsd:string">
		<xsl:value-of select="14" />
	</xsl:variable>
	
	Un exemple de changement :
	
	<!-- Une variable qui a pour but de stocker le numéro de ligne dont on veut afficher le plan -->
	<xsl:variable name="numero-ligne" as="xsd:string">
		<xsl:value-of select="'7B'" />
	</xsl:variable>
	
-- La commande : java -jar saxon-he-10.3.jar -s:fichier_xml.xml -xsl:stylesheet.xsl -o:out.svg
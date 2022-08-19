<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:fun="http://www.omega-one.org/~carton"
    xmlns="http://www.w3.org/2000/svg">
	
	<xsl:output indent="yes"/>
	
	<!-- Variables globales -->
	
	<!-- Une variable qui a pour but de stocker le numéro de ligne dont on veut afficher le plan -->
	<xsl:variable name="numero-ligne" as="xsd:string">
		<xsl:value-of select="'13'" />
	</xsl:variable>
	
	<!-- Le nombre de stations de la ligne essentiellement avant d'ajouter les stations qui fonctionnent uniquement dans le sens opposé et les extensions de la ligne vers différentes destinations -->
	<xsl:variable name="nb-stations" as="xsd:integer">
		<xsl:value-of select="count(/ratp/services/service[./numero = $numero-ligne]/trajet[1]/station)" />
	</xsl:variable>
	
	<!-- Le but de ce template avec paramètres est d'ajouter une station au plan de (le cercle et le nom de la station) -->
	<xsl:template name="fun:ajout-station-au-plan">
		<xsl:param name="cx" select="60" />
		<xsl:param name="cy" select="300" />
		<xsl:param name="nom-station" select="'nom'" /> <!-- Le nom de la station de métro -->
		<xsl:param name="station-base-avec-alternative" select="0" /> <!-- S'agit-il d'une station de l'itinéraire de base avec alternative  ? -->
		<xsl:param name="station-direction-opposee" select="0" /> <!-- Est-ce une station qui n'apparaît que dans la direction opposée ? -->
		<xsl:param name="station-itineraire-alternatif" select="0" /> <!-- S'agit-il d'une station qui n'apparaît que sur un itinéraire alternatif ? -->
		<xsl:param name="nb-correspondances" select="0" /> <!-- Le nombre de correspondances à cette station de métro -->
		
		<!-- Une action visant à mettre à jour y afin d'afficher la station au-dessus ou au-dessous de l'itinéraire régulier, dans le cas des lignes qui ont plus d'un itinéraire -->
		<xsl:variable name="y" select="xsd:int($cy - ($station-base-avec-alternative * 40) + ($station-direction-opposee * 40) + ($station-itineraire-alternatif * 40))" as="xsd:integer" />
		
		<!-- Pour chaque arrêt supplémentaire sur le plan, nous devons prolonger la ligne horizontale qui représente l'itinéraire -->
	    <line x1="{$cx - 27}" y1="{$y}" x2="{$cx -10}" y2="{$y}" stroke="green" stroke-width="6" stroke-linecap="round" />
		
		<!-- Ajout du cercle qui représente la statation sur le plan -->
		<xsl:choose> <!-- xsl:choose : conditionnelle à alternatives multiples -->
			<xsl:when test="$nb-correspondances = 0">
				<!-- Lorsque la station n'a pas de correspondance, le cercle sera vert -->
				<circle cx="{$cx}" cy="{$y}" r="10" fill="green" stroke="green" stroke-width="2" />
			</xsl:when>
			<xsl:otherwise>
				<!-- Lorsque la station a des correspondances, le cercle sera blanc avec un cadre noir -->
				<circle cx="{$cx}" cy="{$y}" r="10" fill="white" stroke="black" stroke-width="2" /> 
			</xsl:otherwise>
		</xsl:choose>
		
		<!-- Ajout de contenu textuel : Le nom de la station de métro -->
		<text transform="translate ({$cx - 2 - ($station-base-avec-alternative * 40) + ($station-base-avec-alternative * 40)}, {$y - 15 + ($station-itineraire-alternatif * 40)+ ($station-direction-opposee * 30)}) rotate({-80 + ($station-itineraire-alternatif * 140)+ ($station-direction-opposee * 140)})" font-family="Verdana" font-size="14" fill="green"> 
 			<xsl:value-of select="$nom-station" /> <!-- Le nom de la station de métro --> 
		</text>
	</xsl:template> <!-- xsl:template name="fun:ajout-station-au-plan" -->
		
	<xsl:template name="fun:ajout-correspondance">
		<xsl:param name="liste-correspondances" select="1" />
		<xsl:param name="counter" select="0" />
		<xsl:param name="arret" select="1" />
		<xsl:param name="station-base-avec-alternative" select="0" /> <!-- S'agit-il d'une station de l'itinéraire de base avec alternative  ? -->
		<xsl:param name="station-direction-opposee" select="0" /> <!-- Est-ce une station qui n'apparaît que dans la direction opposée ? -->
		<xsl:param name="station-itineraire-alternatif" select="0" /> <!-- S'agit-il d'une station qui n'apparaît que sur un itinéraire alternatif ? -->
		
		
		<xsl:variable name="nb-correspondances" select="count($liste-correspondances)" as="xsd:integer" />

		<xsl:if test="$nb-correspondances != 0">
			<xsl:if test="$counter = 0">
				<line x1="{60 + (40 * $arret)}" y1="{300 - ($station-base-avec-alternative * 40) + ($station-direction-opposee * 20)+ ($station-itineraire-alternatif * 20)}" x2="{60 + (40 * $arret)}" y2="{325 + (4 * $nb-correspondances)- ($station-base-avec-alternative * 40) + ($station-direction-opposee * 20)+ ($station-itineraire-alternatif * 20)}" stroke="black" stroke-width="1" stroke-linecap="round"/>
			</xsl:if>
		
			<circle cx="{60 + (40 * $arret)}" cy="{325 + (22 * $counter) - ($station-base-avec-alternative * 42) - ($station-direction-opposee * 10) - ($station-itineraire-alternatif * 10)}" r="10" fill="blue" stroke="blue" stroke-width="2"/> 
			<text x="{(60 + (40 * $arret)- 7)}" y="{325 + (22 * $counter) + 5  - ($station-base-avec-alternative * 42) - ($station-direction-opposee * 10)- ($station-itineraire-alternatif * 10)}" font-family="serif" font-weight="bold" font-size="15" fill="white">
				<xsl:value-of select="$liste-correspondances[position() = 1]"/> 
			</text>
			
		<xsl:call-template name="fun:ajout-correspondance">
				<xsl:with-param name="liste-correspondances" select="remove($liste-correspondances, 1)" />
				<xsl:with-param name="counter" select="$counter + 1" />
				<xsl:with-param name="arret" select="$arret"/>
				<xsl:with-param name="station-base-avec-alternative" select="$station-base-avec-alternative" /> <!-- S'agit-il d'une station de l'itinéraire de base avec alternative  ? -->
				<xsl:with-param name="station-direction-opposee" select="$station-direction-opposee" /> <!-- Est-ce une station qui n'apparaît que dans la direction opposée ? -->
				<xsl:with-param name="station-itineraire-alternatif" select="$station-itineraire-alternatif" /> <!-- S'agit-il d'une station qui n'apparaît que sur un itinéraire alternatif ? -->
			</xsl:call-template>
		</xsl:if> 
	</xsl:template>

	<xsl:template match="/">
	    <!-- La structure générale du fichier svg -->
   		<svg  xmlns="http://www.w3.org/2000/svg"
      		  version="1.0"
              xmlns:xlink="http://www.w3.org/1999/xlink">
    		
    		<!-- Ajout d'une ligne de départ pour le plan de la ligne de métro -->
    		<line x1="20" y1="300" x2="100" y2="300" stroke="green" stroke-width="6" stroke-linecap="round"/>
    		
    		<!-- Nous commençons par faire une application du template de service. 
    		On choisit l'élément service dont l'élément fils numero indique le numéro de la ligne de métro qui nous intéresse -->
   			<xsl:apply-templates select="ratp/services/service[./numero = $numero-ligne]"/>
		</svg>
	</xsl:template> <!-- Fin de <xsl:template match="/"> -->
  	
  	
  	<!-- 
  	Station de métro dans la liste des stations de métro sous la balise <stations>. 
  	Chaque station comprend le de la station, de l'adresse, etc. 
  	Ultérieurement, en détaillant la liste des stations de chaque itinéraire, 
  	seul le numéro d'identification de la stations est indiqué et fait en fait référence à cet élément.
  	 -->
	<xsl:template match="station[@id]"> 
    	<xsl:param name="arret" select="1" /> <!-- Le numéro d'arrêt de la station que nous voulons ajouter au plan -->
    	<xsl:param name="nb-correspondances" select="0" /> <!-- Le nombre de correspondances à cette station de métro -->
    	<xsl:param name="station-base-avec-alternative" select="0" /> <!-- S'agit-il d'une station de l'itinéraire de base avec alternative ? -->
    	<xsl:param name="station-direction-opposee" select="0" /> <!-- Est-ce une station qui n'apparaît que dans la direction opposée ? -->
    	<xsl:param name="station-itineraire-alternatif" select="0" /> <!-- S'agit-il d'une station qui n'apparaît que sur un itinéraire alternatif ? -->
    	
    	<xsl:call-template name="fun:ajout-station-au-plan">
			<xsl:with-param name="cx" select="60 + (40 * $arret)" />
			<xsl:with-param name="cy" select="300" />
			<xsl:with-param name="nom-station" select="nom" /> <!-- Le nom de la station de métro -->
			<xsl:with-param name="station-base-avec-alternative" select="$station-base-avec-alternative" /> <!-- S'agit-il d'une station de l'itinéraire de base avec alternative ? -->
			<xsl:with-param name="station-direction-opposee" select="$station-direction-opposee" /> <!-- Est-ce une station qui n'apparaît que dans la direction opposée ? -->
			<xsl:with-param name="station-itineraire-alternatif" select="$station-itineraire-alternatif" /> <!-- S'agit-il d'une station qui n'apparaît que sur un itinéraire alternatif ? -->
			<xsl:with-param name="nb-correspondances" select="$nb-correspondances" /> <!-- Le nombre de correspondances à cette station de métro -->
		</xsl:call-template>
	</xsl:template>
	
	<!-- 
	Une station de métro qui apparaît sous la balise <trajet>, a pour but d'indiquer que cet itinéraire a un arrêt à cette station,
	ainsi qu'une indication (en tant qu'attribut) du numéro d'arrêt par rapport au début de l'itinéraire. 
	
	Les éléments <station> dans ce cas ont également un attribut appelé ref-id qui représente l'id de la station dans la liste des stations, 
	de cette façon vous pouvez obtenir plus de détails sur la station : nom, adresse, etc.
	
	Ce template a 4 rôles, nous les distinguons à l'aide du paramètre mode (par défaut : mode = 1).
	Mode 1 : Ajouter une station au plan
	Mode 2 : Donne des informations sur le numéro de ligne auquel appartient un élément <station> particulier, nous l'utilisons lors de la recherche de correspondances.
	Mode 3 : Signifie que nous cherchons le numero d'arret d'une station de l'itinéraire de base qui a une alternative dans la direction opposée
	Mode 4 : Signifie que nous cherchons le numero d'arret d'une station de l'itinéraire de base qui a une alternative dans un autre itinéraire
	-->
	<xsl:template match="station[@ref-id]"> 
    	<xsl:param name="mode" select="1" /> <!-- Ce template a 4 rôles, nous les distinguons à l'aide du paramètre mode -->
		<xsl:param name="liste-toutes-stations-base-avec-alternative" select="()" /> <!-- la liste de toutes les stations de l'itinéraire de base qui ont une alternative en sens inverse ou dans un autre itinéraire -->
		<xsl:param name="stations-sens-inverse" select="()" /> <!-- Les stations en sens inverse à ajouter -->
		<xsl:param name="stations-itineraire-alternatif" select="()" /> <!-- la liste des stations de l'itinéraire alternatif à ajouter -->
		
   		<xsl:variable name="ref-id-station" select="@ref-id" as="xsd:IDREF" />
   		<xsl:variable name="trajet-id-station" select="../@id" as="xsd:ID" />
   		
   		<xsl:choose> <!-- Ce template a 4 rôles, nous les distinguons à l'aide du paramètre mode -->
   			
   			<!-- Pour la liste des stations de l'itinéraire de base qui ont une alternative dans un autre itinéraire -->
   			<!-- Mode 4 : Signifie que nous cherchons le numero d'arret d'une station de l'itinéraire de base qui a une alternative dans un autre itinéraire -->
   			<xsl:when test="$mode = 4"> 
   				<xsl:value-of select="@arret" />
   			</xsl:when>
   			
   			<!-- Pour la liste des stations de l'itinéraire de base qui ont une alternative dans la direction opposée -->
   			<!-- Mode 3 signifie que nous cherchons le numero d'arret d'une station de l'itinéraire de base qui a une alternative dans la direction opposée -->
   			<xsl:when test="$mode = 3">
   				<!-- Lorsque l'on a le numéro d'une arret dans le sens inverse, 
   				pour trouver la station correspondante dans le sens fondamental il faut se rappeler que,
   				par exemple, un arrêt dans le sens inverse avec le numéro 17, l'équivalent dans le sens fondamental est l'arrêt numéro 4, 
   				on effectue donc le calcul suivant, qui nous donne 4 comme resultat, étant donné qu'on parle d'un arrêt 17. -->
   				<xsl:value-of select="$nb-stations - @arret + 1" />
   			</xsl:when>
   			
   			<!-- Mode 2 : Donne des informations sur le numéro de ligne auquel appartient un élément <station> particulier, nous l'utilisons lors de la recherche de correspondances. -->
   			<xsl:when test="$mode = 2">
   				<xsl:value-of select="parent::*/parent::*/numero/text()" />
   			</xsl:when>
   			
   			<xsl:when test="$mode = 1">
   				<xsl:variable name="correspondance" as="xsd:string*">
   		   			<xsl:apply-templates select="/ratp/services/service/trajet/station[(@ref-id = $ref-id-station) and (../@id != $trajet-id-station)]">
      					<!-- Valeur du paramètre mode pour l'appel -->
      					<xsl:with-param name="mode" select="2"/> <!-- Mode 2 : Donne des informations sur le numéro de ligne auquel appartient un élément <station> particulier, nous l'utilisons lors de la recherche de correspondances. -->
   					</xsl:apply-templates>
  				</xsl:variable>
  				
   				
   				<xsl:variable name="correspondances" select="tokenize(substring-after(string-join((' ', $correspondance), ':'), ':'),':')" as="xsd:string*" />
      	 	 
      	 	 	<xsl:variable name="arret" select="xsd:integer(abs(xsd:int(not(empty($stations-sens-inverse))) * $nb-stations -  @arret + xsd:int(not(empty($stations-sens-inverse))) *1))" as="xsd:integer" />
      	 	 
      	 		<xsl:call-template name="fun:ajout-correspondance">
					<xsl:with-param name="liste-correspondances" select="$correspondances" />
					<xsl:with-param name="arret" select="$arret"/>
					<xsl:with-param name="station-base-avec-alternative" select="xsd:int(not (empty(index-of($liste-toutes-stations-base-avec-alternative, @arret))))"/> <!-- S'agit-il d'une station de l'itinéraire de base avec alternative ? -->
      				<xsl:with-param name="station-direction-opposee" select="xsd:int(count($stations-sens-inverse) > 0)"/> <!-- Est-ce une station qui n'apparaît que dans la direction opposée ? -->
					<xsl:with-param name="station-itineraire-alternatif" select="xsd:int(count($stations-itineraire-alternatif) > 0)" /> <!-- S'agit-il d'une station qui n'apparaît que sur un itinéraire alternatif ? -->
				</xsl:call-template>

				<xsl:apply-templates select="/ratp/stations/station[@id = $ref-id-station]">
      				<xsl:with-param name="arret" select="$arret"/>
      				<xsl:with-param name="nb-correspondances" select="count($correspondances)"/> <!-- Le nombre de correspondances à cette station de métro -->
      				<xsl:with-param name="station-base-avec-alternative" select="xsd:int(not (empty(index-of($liste-toutes-stations-base-avec-alternative, @arret))))"/> <!-- S'agit-il d'une station de l'itinéraire de base avec alternative ? -->
      				<xsl:with-param name="station-direction-opposee" select="xsd:int(count($stations-sens-inverse) > 0)"/> <!-- Est-ce une station qui n'apparaît que dans la direction opposée ? -->
      				<xsl:with-param name="station-itineraire-alternatif" select="xsd:int(count($stations-itineraire-alternatif) > 0)"/> <!-- S'agit-il d'une station qui n'apparaît que sur un itinéraire alternatif ? -->
   				</xsl:apply-templates>

   			</xsl:when>
   			
   		</xsl:choose>
   
	</xsl:template> <!-- Fin de <xsl:template match="station[@ref-id]">  -->
	
	
	 <!-- Dans <xsl:template match="/"> nous commençons par faire une application du template de service. 
    On choisit l'élément service dont l'élément fils <numero> indique le numéro de la ligne de métro qui nous intéresse 
    -->
	<xsl:template match="service">
		<!-- Nous cherchons la liste des stations de l'itinéraire de base qui ont une alternative dans la direction opposée -->
		<xsl:variable name="stations-base-avec-alternative-direction-opposee" as="xsd:string*">
	   		<xsl:apply-templates select="trajet[@direction = 1]" /> <!-- Un élément trajet avec la valeur 1 pour l'attribut direction est un trajet dans la direction opposée. -->
	 	</xsl:variable>
	   	
	   	<!-- Liste des stations de l'itinéraire de base qui ont une alternative dans la direction opposée -->
	    <xsl:variable name="liste-stations-base-avec-alternative-direction-opposee" select="tokenize(substring-after(string-join((' ', $stations-base-avec-alternative-direction-opposee), ':'), ':'),':')" as="xsd:string*" />
	   	
	   	<!-- Nous cherchons la liste des stations de l'itinéraire de base qui ont une alternative dans un autre itinéraire -->
	   <xsl:variable name="stations-base-avec-alternative-autre-itineraire" as="xsd:string*">
	   		<xsl:apply-templates select="trajet[@direction = 0 and position() != 1]" />
	   </xsl:variable>
	   	
	   	<!-- Liste des stations de l'itinéraire de base qui ont une alternative dans un autre itinéraire -->
	   <xsl:variable name="liste-stations-base-avec-alternative-autre-itineraire" select="tokenize(substring-after(string-join((' ', $stations-base-avec-alternative-autre-itineraire), ':'), ':'),':')" as="xsd:string*" />
	   	
	   	<xsl:choose>
	   		<xsl:when test="count($liste-stations-base-avec-alternative-autre-itineraire) > 0">
   				<xsl:variable name="min" select="min($liste-stations-base-avec-alternative-autre-itineraire)"/> 
   				
   				<line x1="{60 + (40 * ($min -1))}" y1="290" x2="{60 + (40 * ($min -1)) + 10}" y2="260" stroke="green" stroke-width="6"  stroke-linecap="round"/>
   				<line x1="{60 + (40 * ($min -1))}" y1="310" x2="{60 + (40 * ($min -1)) + 10}" y2="340" stroke="green" stroke-width="6"  stroke-linecap="round"/>
	   		</xsl:when>
	   		
	   		<xsl:when test="count($liste-stations-base-avec-alternative-direction-opposee) > 0">
				<xsl:variable name="min" select="min($liste-stations-base-avec-alternative-direction-opposee)"/> 
   				
   				<line x1="{60 + (40 * ($min -1))}" y1="290" x2="{60 + (40 * ($min -1)) + 10}" y2="260" stroke="green" stroke-width="6"  stroke-linecap="round"/>
   			    <line x1="{60 + (40 * ($min -1))}" y1="310" x2="{60 + (40 * ($min -1)) + 10}" y2="340" stroke="green" stroke-width="6"  stroke-linecap="round"/>
   			    
   			    <xsl:variable name="max" select="max($liste-stations-base-avec-alternative-direction-opposee)"/> 
   				
   				<line x1="{60 + (40 * ($max))}" y1="260" x2="{60 + (40 * ($max)) + 10}" y2="300" stroke="green" stroke-width="6"  stroke-linecap="round"/>
   			    <line x1="{60 + (40 * ($max))}" y1="340" x2="{60 + (40 * ($max)) + 10}" y2="300" stroke="green" stroke-width="6"  stroke-linecap="round"/>
	   		</xsl:when>
	   	</xsl:choose>
   		
	   	
	   	<!-- Ajout des stations de l'itinéraire de base au plan -->
	   	
	   	<!-- Un élément trajet avec la valeur 0 pour l'attribut direction est un trajet dans la direction "régulière" (trajet de base).
	   	Nous choisissons le premier élément <trajet> avec direction = 0 car s'il y a des éléments supplémentaires de trajet avec cette valeur,
	   	les éléments supplémentaires représentent des chemins alternatifs, nous les ajouterons plus tard -->
	   	<xsl:apply-templates select="trajet[@direction = 0 and position() = 1]">
	   			<!-- insert-before(), Premier argument : liste des stations de l'itinéraire de base qui ont une alternative dans la direction opposée -->
	   			<!-- insert-before(), Deuxième argument : liste des stations de l'itinéraire de base qui ont une alternative dans un autre itinéraire -->
	   			
	   			<!-- On passe en paramètre la liste de toutes les stations de l'itinéraire de base 
	   			qui ont une alternative en sens inverse ou dans un autre itinéraire. Le but est que
	   			lorsque l'on ajoute une station, on puisse savoir s'il s'agit d'une station avec une alternative,
	   			et si c'est le cas, on peut agir en conséquence et la présenter plus haut sur le plan,
	   			au dessus de la ligne du parcours régulier -->
	   			
	   			<!-- item()* insert-before(item()* l1, xsd:integer pos, item()* l2)  -->
	   			<!-- retourne la liste obtenue en insérant la liste l2 dans la liste l1 à la position pos. -->
	   			<xsl:with-param name="liste-toutes-stations-base-avec-alternative" select="insert-before($liste-stations-base-avec-alternative-direction-opposee, 0, $liste-stations-base-avec-alternative-autre-itineraire)"/>
	   	</xsl:apply-templates>
	   	
	   	<!-- Ajout des stations dans la direction opposée au plan -->
	   	<xsl:apply-templates select="trajet[@direction = 1]"> <!-- Un élément trajet avec la valeur 1 pour l'attribut direction est un trajet dans la direction opposée. -->
	   		<xsl:with-param name="stations-sens-inverse" select="$liste-stations-base-avec-alternative-direction-opposee"/> <!-- Les stations en sens inverse à ajouter -->
	   		<xsl:with-param name="mode" select="2"/> <!-- Ce template a 2 rôles, nous les distinguons à l'aide du paramètre mode -->
	   	</xsl:apply-templates>
	   	
	   	<!-- Ajout des stations de l'itinéraire alternatif au plan -->
	   	<!-- Un élément trajet avec la valeur 0 pour l'attribut direction est un trajet dans la direction "régulière" (trajet de base).
	   	Nous choisissons PAS le premier élément <trajet> avec direction = 0 car s'il y a des éléments supplémentaires de trajet avec cette valeur,
	   	les éléments supplémentaires représentent des chemins alternatifs, ce sont les éléments auxquels appartiennent les stations que nous voulons ajouter -->
	   	<xsl:apply-templates select="trajet[@direction = 0 and position() != 1]">
	   		<!-- Liste des stations de l'itinéraire de base qui ont une alternative dans un autre itinéraire -->
	   		<xsl:with-param name="stations-itineraire-alternatif" select="$liste-stations-base-avec-alternative-autre-itineraire"/> <!-- la liste des stations de l'itinéraire alternatif à ajouter -->
	   		<xsl:with-param name="mode" select="2"/> <!-- Ce template a 2 rôles, nous les distinguons à l'aide du paramètre mode -->
	   	</xsl:apply-templates>
	   	
	</xsl:template> <!-- Fin de <xsl:template match="service"> -->
	
    <!-- Un élément trajet avec la valeur 0 pour l'attribut direction est un trajet dans la direction "régulière" (direction de base).
	Nous ne choisissons le premier élément <trajet> avec direction = 0 car s'il y a des éléments supplémentaires de trajet avec cette valeur,
	les éléments supplémentaires représentent des chemins alternatifs -->
	<xsl:template match="trajet[@direction = 0 and position() = 1]">
		<!-- la liste de toutes les stations de l'itinéraire de base qui ont une alternative en sens inverse ou dans un autre itinéraire -->
		<xsl:param name="liste-toutes-stations-base-avec-alternative" select="()"/> 
		
	 	<xsl:apply-templates select="station"> <!-- Ajout des stations de l'itinéraire de base au plan -->
	 		<xsl:with-param name="liste-toutes-stations-base-avec-alternative" select="$liste-toutes-stations-base-avec-alternative"/>
	 	</xsl:apply-templates>
	</xsl:template> <!-- Fin de <xsl:template match="trajet[@direction = 0 and position() = 1]"> -->
	
	<!-- 
	Un élément trajet avec la valeur 1 pour l'attribut direction est un trajet dans la direction opposée.
	Ce template a 2 rôles, nous les distinguons à l'aide du paramètre mode (par défaut : mode = 1).
	
	Mode 1 signifie que nous cherchons la liste des stations de l'itinéraire de base qui ont une alternative dans la direction opposée
	Mode 2 signifie qu'on récupère en paramètre la liste des stations en sens inverse à ajouter et on les ajoute au plan
	-->
	<xsl:template match="trajet[@direction = 1]">
	    <xsl:param name="stations-sens-inverse" select="()"/> <!-- Les stations en sens inverse à ajouter -->
	   	<xsl:param name="mode" select="1"/> <!-- Ce template a 2 rôles, nous les distinguons à l'aide du paramètre mode -->
	   	
	   	<xsl:choose>
	   		<!-- Mode 2 signifie qu'on récupère en paramètre la liste des stations en sens inverse à ajouter et on les ajoute au plan -->
	   		<xsl:when test="$mode = 2">
	   			<xsl:apply-templates select="station">
	 				<xsl:with-param name="stations-sens-inverse" select="$stations-sens-inverse"/> <!-- Les stations en sens inverse à ajouter -->
	 			</xsl:apply-templates>
	   		</xsl:when>
	   		
	   		<!-- Mode 1 signifie que nous cherchons la liste des stations de l'itinéraire de base qui ont une alternative dans la direction opposée -->
	   		<xsl:when test="$mode = 1">
	   			<!-- Liste des stations de l'itinéraire de base qui ont une alternative dans la direction opposée -->
	    		<xsl:variable name="stations-base-avec-alternative-direction-opposee" as="xsd:string*">
	 	 			<xsl:apply-templates select="station">
      					<xsl:with-param name="mode" select="3"/> <!-- Mode 3 signifie que nous cherchons le numero d'arret d'une station de l'itinéraire de base qui a une alternative dans la direction opposée -->
   		 			</xsl:apply-templates>
   				</xsl:variable>
   		
   				<xsl:variable name="liste-stations-base-avec-alternative-direction-opposee" select="(substring-after(string-join((' ', $stations-base-avec-alternative-direction-opposee), ':'), ':'),':')" as="xsd:string*" />
   				<xsl:value-of select="$liste-stations-base-avec-alternative-direction-opposee" />
	   		</xsl:when>
	   	</xsl:choose>
	</xsl:template> <!-- La fin de <xsl:template match="trajet[@direction = 1]"> -->
	
	<!-- Un élément trajet avec la valeur 0 pour l'attribut direction est un trajet dans la direction "régulière" (direction de base).
	Nous ne choisissons PAS le premier élément <trajet> avec direction = 0 car s'il y a des éléments supplémentaires de trajet avec cette valeur,
	les éléments supplémentaires représentent des chemins alternatifs, ce sont les éléments auxquels appartiennent les stations que nous voulons ajouter
	
	Ce template a 2 rôles, nous les distinguons à l'aide du paramètre mode (par défaut : mode = 1).
	Mode 1 signifie que nous cherchons la liste des stations de l'itinéraire de base qui ont une alternative dans un autre itinéraire
	Mode 2 signifie qu'on récupère en paramètre la liste des stations de l'itinéraire alternatif à ajouter et on les ajoute au plan
	 -->
	<xsl:template match="trajet[(position() != 1) and (@direction = 0)]">
		<xsl:param name="stations-itineraire-alternatif" select="()"/> <!-- la liste des stations de l'itinéraire alternatif à ajouter -->
	   	<xsl:param name="mode" select="1"/> <!-- Ce template a 2 rôles, nous les distinguons à l'aide du paramètre mode -->
	   	
	   	<xsl:choose>
	   		<!-- Mode 2 signifie qu'on récupère en paramètre la liste des stations de l'itinéraire alternatif à ajouter et on les ajoute au plan -->
	   		<xsl:when test="$mode = 2">
	   			<xsl:apply-templates select="station">
	 				<!-- la liste des stations de l'itinéraire alternatif à ajouter -->
	 				<xsl:with-param name="stations-itineraire-alternatif" select="$stations-itineraire-alternatif"/>
	 			</xsl:apply-templates>
	   		</xsl:when>
	   		
	   		<!-- Mode 1 signifie que nous cherchons la liste des stations de l'itinéraire de base qui ont une alternative dans un autre itinéraire -->
	   		<xsl:when test="$mode = 1">
	   			<!-- Liste des stations de l'itinéraire de base qui ont une alternative dans un autre itinéraire -->
	    		<xsl:variable name="stations-base-avec-alternative-autre-itineraire" as="xsd:string*">
	 	 			<xsl:apply-templates select="station">
      					<xsl:with-param name="mode" select="4"/>
   		 			</xsl:apply-templates>
   				</xsl:variable>
   		
   				<xsl:variable name="liste-stations-base-avec-alternative-autre-itineraire" select="(substring-after(string-join((' ', $stations-base-avec-alternative-autre-itineraire), ':'), ':'),':')" as="xsd:string*" />
   				<xsl:value-of select="$liste-stations-base-avec-alternative-autre-itineraire" />
	   		</xsl:when>
	   	</xsl:choose>
	</xsl:template> <!-- Fin de <xsl:template match="trajet[(position() != 1) and (@direction = 0)]"> -->
	
</xsl:stylesheet>
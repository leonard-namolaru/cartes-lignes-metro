#-*- coding:utf-8 -*-
'''
* extracteur.py
* Projet de XML : Cartes des lignes du métro
* M1 : Master Informatique fondamentale et appliquee - Universite Paris Cité.
'''

from xml.dom.minidom import *
from xml.dom import minidom
import sys

def main() :
    if (len(sys.argv) < 2) : 
        print('Veuillez transmettre au programme un chemin d acces au fichier csv en tant que parametre via la ligne de commande.')
        sys.exit(0)
    
    fichier_csv_path = fichier_csv_path =  sys.argv[1]
    nom_fichier_xml = "fichier_xml.xml"
    print('Le logiciel va maintenant convertir le fichier csv en un fichier xml nommé ' + nom_fichier_xml + '. Le processus peut prendre un temps relativement long...')

    fichier_csv = open(fichier_csv_path, "r", encoding='utf-8')
    document = Document()
    
    noeud_racine = document.createElement("ratp")
    document.appendChild(noeud_racine)
    commentaire = document.createComment("Traduction du fichier base_ratp.csv en fichier xml")
    noeud_racine.appendChild(commentaire)
    
    stations = document.createElement("stations")
    noeud_racine.appendChild(stations)
    commentaire = document.createComment("Liste de toutes les stations de métro")
    stations.appendChild(commentaire)
    
    services = document.createElement("services")
    noeud_racine.appendChild(services)
    commentaire = document.createComment("Liste de tous les services offerts par le réseau de métro (liste de toutes les lignes)")
    services.appendChild(commentaire)
    
    i = 0
    for line in fichier_csv :
        liste_of_line = line.split(';')
        
        # La première ligne du fichier contient les en-têtes de colonnes, cela ne nous intéresse pas
        if (i == 0) :
            i = i + 1
            continue
        
        station_existe_deja = False
        service_existe_deja = False
        trajet_existe_deja = False
        ref_station_existe_deja_dans_service = False
        
        service_j = None
        trajet_j = None
        if (i > 1) :
            fichier_xml = open(nom_fichier_xml, "rb")
            xml_ducument =  minidom.parse(fichier_xml)
            for j in range(0, xml_ducument.getElementsByTagName("station").length) :
                if (xml_ducument.getElementsByTagName("station")[j].getAttribute("id") == 'id' + str(liste_of_line[0])  ) :
                    station_existe_deja = True
                    break
                
            for j in range(0, xml_ducument.getElementsByTagName("service").length) :
                if (xml_ducument.getElementsByTagName("service")[j].getAttribute("id") == 'id' + str(liste_of_line[7]) ) :
                    service_existe_deja = True
                    service_j = j
                    
                    reference_enfants_service = xml_ducument.getElementsByTagName("service")[j].childNodes
                    # Nous parcourons toute la liste les elements enfants de service
                    for r in range (0,  reference_enfants_service.length) :
                        if (reference_enfants_service.item(r).nodeType != reference_enfants_service.item(r).TEXT_NODE) :
                            # Si il sagit dun element de type trajet
                            if (reference_enfants_service.item(r).tagName.lower() == 'trajet') :
                                reference_enfants_trajet = xml_ducument.getElementsByTagName("service")[j].childNodes[r].childNodes
                                # Nous parcourons toute la liste les elements enfants de trajet
                                for k in range (0,  reference_enfants_trajet.length) :
                                    # Si l'élément actuel n'est pas un text node
                                    if (reference_enfants_trajet.item(k).nodeType != reference_enfants_trajet.item(k).TEXT_NODE) :
                                        # Si il sagit dun element de type station
                                        if (reference_enfants_trajet.item(k).tagName.lower() == 'station') :
                                            if (reference_enfants_trajet.item(k).getAttribute('ref-id').lower() == 'id' + str(liste_of_line[0]) ) :
                                                ref_station_existe_deja_dans_service = True
                                                break
                    break
                
            for j in range(0, xml_ducument.getElementsByTagName("trajet").length) :
                if (xml_ducument.getElementsByTagName("trajet")[j].getAttribute("id") == 'id' + str(liste_of_line[6]) ) :
                    trajet_existe_deja = True
                    trajet_j = j                            
                    break

            fichier_xml.close()
        
        fichier_xml = open(nom_fichier_xml, "bw")
        
        if (not station_existe_deja) :
            # Ajout d'une nouvelle station de métro
            station = document.createElement("station")
            station.setAttribute("id", 'id' + str(liste_of_line[0]))
            stations.appendChild(station)

            # Ajout du nom de la nouvelle station de métro
            nom_station = document.createElement("nom")
            contenu_nom_station = document.createTextNode(liste_of_line[1])
            nom_station.appendChild(contenu_nom_station)
            station.appendChild(nom_station)
            
            # Ajout de l'adresse de la nouvelle station de métro
            adresse_station = document.createElement("adresse")
            contenu_adresse_station = document.createTextNode(liste_of_line[2])
            adresse_station.appendChild(contenu_adresse_station)
            station.appendChild(adresse_station)
        
            # Ajout de latitude de la nouvelle station de métro
            latitude_station = document.createElement("latitude")
            contenu_latitude_station = document.createTextNode(liste_of_line[3])
            latitude_station.appendChild(contenu_latitude_station)
            station.appendChild(latitude_station)
            
            # Ajout de longitude de la nouvelle station de métro
            longitude_station = document.createElement("longitude")
            contenu_longitude_station = document.createTextNode(liste_of_line[4])
            longitude_station.appendChild(contenu_longitude_station)
            station.appendChild(longitude_station)
        
        service = None                
        if (not service_existe_deja) :
            # Ajout d'une nouvelle ligne de métro (un nouveau service)
            service = document.createElement("service")
            service.setAttribute("id", 'id' + str(liste_of_line[7]))
            services.appendChild(service)
            
            # Ajout du le numéro de la ligne de métro
            numero = document.createElement("numero")
            contenu_numero = document.createTextNode(liste_of_line[9])
            numero.appendChild(contenu_numero)
            service.appendChild(numero)
            
        if (service_j != None) :
            service = document.getElementsByTagName("service")[service_j]

        trajet = None
        if (not trajet_existe_deja) :
            # Ajout d'un nouveau trajet
            trajet = document.createElement("trajet")
            trajet.setAttribute("id", 'id' + str(liste_of_line[6]))
            trajet.setAttribute("direction", liste_of_line[8])
            service.appendChild(trajet)
        
        if (trajet_j != None) :
            trajet = document.getElementsByTagName("trajet")[trajet_j]
        
        if (not ref_station_existe_deja_dans_service) :
            # Ajout d'une nouvelle ref pour une station de métro du trajet
            station = document.createElement("station")
            station.setAttribute("ref-id", 'id' + str(liste_of_line[0]))
            station.setAttribute("arret", liste_of_line[5])
            trajet.appendChild(station)
        
        fichier_xml.write(document.toprettyxml(indent="   ").encode('utf-8'))
        fichier_xml.close()
        i = i + 1
    fichier_csv.close()
    
    

if __name__ == '__main__':
    main()
import Pkg
Pkg.add("Plots")
using Plots


function lecture(nom_fichier::String)
    lignes = readlines(nom_fichier)
    nb_lignes = parse(Int, split(lignes[2])[2])  # On prend la deuxième ligne du fichier que l'on ségmente et on prend la deuxième partie ui correspond à la hauteur et on convertit avec parse en int
    nb_colonnes = parse(Int, split(lignes[3])[2]) # Pareil pour la ligne suivante qui correspond à la largeur
    tab::Matrix{String} = fill(" ", nb_lignes, nb_colonnes)  # Créer un tableau vide de la bonne taille
    
    for i in 1:nb_lignes
        ligne = lignes[i+4]  # Pour ignorer les quatre premières lignes on commence la retranscription à la quatrième ligne
        for j in 1:nb_colonnes
            elem=ligne[j]
            tab[i, j] = string(elem)    # On est sur la i+4 ème ligne et on la parcourt puis on recopie dans le tableau
        end
    end
    
    return tab
end

nom_fichier = "theglaive.map"
function init()
    return (lecture(nom_fichier))
end

function dist_man(p1,p2,poids::Float64 = 1)
    return (float(abs(p1[1]-p2[1])+abs(p1[2]-p2[2]))*poids)
end

function est_valide(p,x,y)
    return(p[1]>0 && p[1]<x+1 && p[2]>0 && p[2]<y+1)                #On vérifie simplement que le point est valide
end

function score(v,tab)
    if tab[v[1],v[2]]=="@"                             #Si le voisin est mur on renvoie la valeur 0 ui est une valeur particulière traitée ailleurs
        return 0
    elseif tab[v[1],v[2]]=="S"  || tab[v[1],v[2]]=="R"                       #Les autres cas prennent en compte les changement que j'apporte au fur et à mesure 
        return 5
    elseif tab[v[1],v[2]]=="W" || tab[v[1],v[2]]=="M"
        return 8
    else 
        return 1
    end
end

function min(l::Vector{Tuple{Tuple{Int, Int}, Int}},fin::Tuple{Int, Int},poids::Float64 = 1.0)                  #Cette fonction nous retourne le point dont la distance de manhattan plus son poids est le plus faible ainsi que son indice dans la liste
	i=1
	elem=l[1]	
	for k in 1:length(l)
		if float(l[k][2])+dist_man(l[k][1],fin,poids)< float(elem[2])+dist_man(elem[1],fin,poids)               #La présence du poids oblige à convertir en float 
			elem=l[k]
			i=k
		end
	end
	return(elem,i)
end

function changement(tab::Matrix{String},i::Tuple{Int, Int})
    if tab[i[1],i[2]]=="S"                             #Je change les lettres afin de visualiser les changements
        tab[i[1],i[2]]="R"
    elseif tab[i[1],i[2]]=="W"                     
        tab[i[1],i[2]]="M"
    else 
        tab[i[1],i[2]]=","
    end 
end

function avancer(parent,cout,tmp::Tuple{Tuple{Int, Int}, Int},tab::Matrix{String})
    nb_lignes, nb_colonnes = size(tab)
    l=[]
    p=tmp[1]
    cpt=0
    voisins = [(p[1]+1, p[2]), (p[1]-1, p[2]), (p[1], p[2]+1), (p[1], p[2]-1)]              
    for i in voisins                                                            #On parcourt la liste des voisins du premier point de la liste
        if est_valide(i, nb_lignes,nb_colonnes)   &&  score(i,tab)>0        #Si il est valide et que ce n'est pas un mur
            poids=tmp[2]+score(i,tab)                                                    #Le poids du voisin, par ce chemin, a pour valeur le poids pour atteindre le point p plus celui entre p et lui même
            if cout[i[1],i[2]]==-1 || cout[i[1],i[2]]>poids                      #Si le cout pour atteindre i n'a pas de valeur ou u'il a une valeur plus grande 
                cout[i[1],i[2]]=poids                                           #On change cette valeur pour qu'elle soit la plus petite
                push!(l,(i,poids))                                              #On ajoute le tuple (i,poids) dans l pour continuer de traiter ce chemin, à noter que si le point i est atteint par un meilleur chemin, ce chemin moins optimal meurt dans les if précédent
                parent[i[1],i[2]]=p                                             #Enfin on donne à i son parent, ici p
                changement(tab,i)                                               #j'utilise cette fonction uniquement pour visualiser ce que fait réellement mon algo
                cpt+=1                                                          #J'ai visité un état donc j'incrément le compteur
            end
        end
    end
    return l,cpt
end
    
function etoile(debut,fin,tab::Matrix{String},poids::Float64)

    nb_lignes, nb_colonnes = size(tab)
    parent::Matrix{Tuple{Int64,Int64}} = fill((-1,-1), nb_lignes, nb_colonnes)      #On initialise une matrice parent avec pour valeur par défaut (-1,-1)
    cout::Matrix{Int64} = fill(-1, nb_lignes, nb_colonnes)                          #On initialise une matrice cout avec pour valeur par défaut -1
    l::Vector{Tuple{Tuple{Int, Int}, Int}}=[(debut,0)]                              #On initialise une liste avec pour valeur [(debut,0)] cette lite va contenir des Tuples de point,valeur la valeur représente le cout u'il nous a fallu pour atteindre ce point(présent dans la matrice cout)
    cout[debut[1],debut[2]]=0                                                       #On initialise le cout pour atteindre le debut à 0 afin de ne pas repasser par ce point
    cpt=1                                                                           #On initialise le cpt d'état visités à 1
    while parent[fin[1],fin[2]]==(-1,-1) && l!=[]                                   #Tant que notre objectif n'a pas de parent ou que la liste l n'est pas vide (cas ou on ne peut pas atteindre le point final)
        suppr=min(l,fin,poids)
        tmp=suppr[1]
        av=avancer(parent,cout,tmp,tab)
        add=av[1]
        cpt=cpt+av[2]
        append!(l,add)
        deleteat!(l,suppr[2])                                                               #On supprime le premier élément de l ce qui nous permet de n'avoir que des éléments non traités dans l
    end
    chemin=[fin]
    i=fin  
    while parent[i[1],i[2]]!=(-1,-1)
        i=parent[i[1],i[2]]
        tab[i[1],i[2]]="C"
        push!(chemin,i)
    end
    #println("Distance entre les deux points:",cout[fin[1],fin[2]] )
    #println("Points visités: ",cpt )
    return(cpt)
end


function temps_executionww()
    x=[]
    y=[]
    cpt=0
    tab=init()
    for k in 0:1000                                     #Toute cette partie sert à créer des graphe pour l'étude des facteurs
        debut = time_ns()
        cpt=etoile((54,224), (466,477),tab,1.0+float(k)/500.0)
        append!(x,1.0+float(k)/500.0)
        #append!(y,cpt)
        fin = time_ns()
        temps_execution=(fin - debut) / 1e9
        append!(y,temps_execution)
        if k==0
            println("Temps d'exécution: ", temps_execution, " secondes")
            println(cpt)
        end
    end

    #plot(x, y, xlabel="Valeurs du poids", ylabel="Nombres de cases visitées", title="Graphique pour un poids par intervalle de 1/500")
    plot(x, y, xlabel="Valeurs du poids", ylabel="Temps d'execution", title="Graphique pour un poids par intervalle de 1/500")
    #scatter(x, y, xlabel="Valeurs du poids", ylabel="Nombres de cases visitées", title="Graphique pour un poids par intervalle de 1/500")nuage de point

    #chemin_fichier = "matrice4.txt"    permettait une étude graphique 
    #open(chemin_fichier, "w") do fichier
        # for i in 1:size(tab)[1]
                #for j in 1:size(tab)[2]
                  #      write(fichier,tab[i,j] )  
               # end
               # write(fichier, "\n")
       # end
   # end
end


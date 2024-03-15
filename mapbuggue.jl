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


function afficher_matrice(matrice::Matrix{String})
    max_taille = maximum(length.(matrice))+1 # Détermine la largeur de champ maximale pour aligner les éléments sur les colonnes

    for i in 1:size(matrice, 1)
        for j in 1:size(matrice, 2)
            s=matrice[i, j]
            while length(s) < max_taille
                s = " $s"
            end
            print(s)
        end
        println()  # Saut de ligne après chaque ligne
    end
end

nom_fichier = "arena2.map"
function init()
    return (lecture(nom_fichier))
end

function est_valide(p,x,y)
    return(p[1]>0 && p[1]<x+1 && p[2]>0 && p[2]<y+1)
end

function avancer(x, y,but, tab::Matrix{String},poids::Matrix{Int64},parent)
    nb_lignes, nb_colonnes = size(tab)
    num::Int = poids[x, y] + 1
    liste = []
    voisins::Vector{Tuple{Int64, Int64}} = [(x+1, y), (x-1, y), (x,y+1), (x,y-1)]
    for v in voisins
        if est_valide(v, nb_lignes, nb_colonnes) && parent[v[1],v[2]]==(-1,-1) && tab[v[1],v[2]]=="."
            poids[v[1],v[2]] = num
            push!(liste, v)
        end
    end
    return liste
end




function flood_fill(depart,but,tab::Matrix{String})
    nb_lignes, nb_colonnes = size(tab)
    poids::Matrix{Int64} = fill(-1, nb_lignes, nb_colonnes)
    parent::Matrix{Tuple{Int64,Int64}} = fill((-1,-1), nb_lignes, nb_colonnes)
    liste=[depart]
    poids[depart[1],depart[2]]=0
    point_string = "."
    while poids[but[1],but[2]]==-1
            i = liste[1]
            l=avancer(i[1],i[2],but,tab,poids,parent)
            append!(liste,l)
            popfirst!(liste)
            for point in l
                parent[point[1],point[2]]=i
            end
    end
    # afficher(parent)
    return parent
end


function resolution(depart,but,tab::Matrix{String})
    parent=flood_fill(depart,but,tab)
    liste=[]
    p=but
    while p!=depart && p!= (-1,-1)
        push!(liste,p)
        p=parent[p[1],p[2]]
    end
    l=reverse(liste)
    println(l)
    return l
end

function synthese(depart,but,tab::Matrix{String})
    l=resolution(depart,but,tab)
    for p in l 
        tab[p[1],p[2]]="C"
    end
    tab[but[1],but[2]]="A"
    tab[depart[1],depart[2]]="D"
    #afficher_matrice(tab)
end

function testt()
    depart = (100,5)
    tab = init()
    synthese((100,5), (201,277), tab)
end
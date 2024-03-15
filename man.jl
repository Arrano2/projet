function lecture(nom_fichier::String)
    lignes = readlines(nom_fichier)
    nb_lignes = parse(Int, split(lignes[2])[2])  # On prend la deuxième ligne du fichier que l'on ségmente et on prend la deuxième partie ui correspond à la hauteur et on convertit avec parse en int
    nb_colonnes = parse(Int, split(lignes[3])[2]) # Pareil pour la ligne suivante qui correspond à la largeur
    tab::Matrix{Char} = fill(' ', nb_lignes, nb_colonnes)  # Créer un tableau vide de la bonne taille
    
    for i in 1:nb_lignes
        ligne = lignes[i+4]  # Pour ignorer les quatre premières lignes on commence la retranscription à la quatrième ligne
        for j in 1:nb_colonnes
            tab[i, j] = ligne[j]    # On est sur la i+4 ème ligne et on la parcourt puis on recopie dans le tableau
        end
    end
    
    return tab
end

function afficher_matrice(matrice)
    for i in 1:size(matrice, 1)
        for j in 1:size(matrice, 2)
            print(matrice[i, j])
        end
        println()  # Saut de ligne
    end
end

nom_fichier = "arena2.map"
function init()
    return (lecture(nom_fichier))
end


function est_valide(p,x,y)
    return(p[1]>0 && p[1]<x+1 && p[2]>0 && p[2]<y+1)
end

function score(p,v,tab)
    if tab[v[1],v[2]]=="@"                             #Si le voisin est mur on renvoie la valeur 0 ui est une valeur particulière traitée ailleurs
        return 0
    elseif tab[p[1],p[2]]=="."                         #Si le point de départ est un point 
        if tab[v[1],v[2]]=="."                         #Si le point d'arrivée en est un aussi on renvoie 1
            return 1
        else                                           #Si le point d'arrivée est quoi que ce soit d'autres on renvoie 3
            return 3
        end
    else                                               #Si le point de départ est quoi que ce soit d'autres qu'un point
        if tab[v[1],v[2]]=="."                         #Si le voisin est un point on renvoie 3
            return 1
        else                                           #Si ce voisin et aussi une case dur à franchir on renvoie 5
            return 5
        end
    end
end

function dist_man(p1,p2)
    return abs(p1[1]-p2[1])+abs(p1[2]-p2[2])
end

function pluscourt(l,p,fin)
    for k in l
        if dist_man(p,fin)<dist_man(k,fin)
            return true
        end
    end
    return false
end

function choix(l, fin, tab, parent, cout)
    nb_lignes, nb_colonnes = size(tab)
    scmin = -1
    liste = []
    p = l[1]
    voisins::Vector{Tuple{Int64, Int64}} = [(p[1]+1, p[2]), (p[1]-1, p[2]), (p[1], p[2]+1), (p[1], p[2]-1)]
    for v in voisins
        if est_valide(v, nb_lignes, nb_colonnes) && score(p, v, tab) != 0 && parent[v[1],v[2]]==(-1,-1) && pluscourt(l,v,fin)
            sc = dist_man(v, fin)
            if sc < scmin || scmin == -1
                liste = [(v[1], v[2])]
                scmin = sc
            end
        end
    end
    println("ajout:",liste)
    cout_p = cout[p[1], p[2]]  # Récupérer la valeur de cout pour le point p
    for k in liste
        if parent[k[1], k[2]] == (-1, -1) || cout[k[1], k[2]] > cout_p + score(p, k, tab)
            parent[k[1], k[2]] = p
            cout[k[1], k[2]] = cout_p + score(p, k, tab)  # Ajouter le score à la valeur de cout pour le point p
        end
    end
    return liste
end

    
function etoile(debut,fin,tab)
    nb_lignes, nb_colonnes = size(tab)
    parent::Matrix{Tuple{Int64,Int64}} = fill((-1,-1), nb_lignes, nb_colonnes)      #On initialise une matrice parent avec pour valeur par défaut (-1,-1)
    cout::Matrix{Int64} = fill(-1, nb_lignes, nb_colonnes)                          #On initialise une matrice cout avec pour valeur par défaut -1
    l::Vector{Tuple{Int, Int}}=[(debut)]                              #On initialise une liste avec pour valeur [(debut,0)] cette lite va contenir des Tuples de point,valeur la valeur représente le cout u'il nous a fallu pour atteindre ce point(présent dans la matrice cout)
    cout[debut[1],debut[2]]=0                                                                   #On initialise le cout pour atteindre le debut à 0 afin de ne pas repasser par ce point
    while parent[fin[1],fin[2]]==(-1,-1) || l!=[]                                             #Tant que notre objectif n'a pas de parent ou ue la liste l n'est pas vide (cas ou on ne peut pas atteindre le point final)
        println("liste :", l)
        l=choix(l,fin,tab,parent,cout)
                                                               #On supprime le premier élément de l ce qui nous permet de n'avoir que des éléments non traités dans l
    end
    chemin=[fin]
    i=fin    
    while parent[i[1],i[2]]!=(-1,-1)
        i=parent[i[1],i[2]]
        push!(chemin,i)
    end
    return(reverse(chemin))
end

function test6()
    tab=init()
    etoile((100,5), (201,277),tab)
end


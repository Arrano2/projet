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

function est_valide(p,x,y)
    return(p[1]>0 && p[1]<x+1 && p[2]>0 && p[2]<y+1)
end

function avancer(x, y,but, tab::Matrix{String},poids::Matrix{Int64},parent)
    cpt=0
    nb_lignes, nb_colonnes = size(tab)
    num::Int = poids[x, y] + 1
    liste = []
    voisins::Vector{Tuple{Int64, Int64}} = [(x+1, y), (x-1, y), (x,y+1), (x,y-1)]
    for v in voisins
        if est_valide(v, nb_lignes, nb_colonnes) && parent[v[1],v[2]]==(-1,-1) && tab[v[1],v[2]]=="."
            poids[v[1],v[2]] = num
            push!(liste, v)
            parent[v[1],v[2]]=(x,y)
            cpt+=1
        end
    end
    return liste,cpt
end




function flood_fill(depart,but,tab::Matrix{String})
    cpt=0
    nb_lignes, nb_colonnes = size(tab)
    poids::Matrix{Int64} = fill(-1, nb_lignes, nb_colonnes)
    parent::Matrix{Tuple{Int64,Int64}} = fill((-1,-1), nb_lignes, nb_colonnes)
    liste=[depart]
    poids[depart[1],depart[2]]=0
    point_string = "."
    while poids[but[1],but[2]]==-1
            i = liste[1]
            l,a=avancer(i[1],i[2],but,tab,poids,parent)
            cpt+=a
            append!(liste,l)
            popfirst!(liste)
    end
    println(cpt)
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

#function synthese(depart,but,tab::Matrix{String})
    #l=resolution(depart,but,tab)
    #for p in l 
     #   tab[p[1],p[2]]="C"
    #end
    #tab[but[1],but[2]]="A"
    #tab[depart[1],depart[2]]="D"
    #afficher_matrice(tab)
#end

function testflood()
    tab = init()
    resolution((189,193), (226,437), tab)
end
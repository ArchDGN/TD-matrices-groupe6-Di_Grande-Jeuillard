# Matrice_C
Tristan JEUILLARD --- Nicolas DI GRANDE --- TD3

# Compte rendu Implémentation des matrices

2) intro du sujet

3) copie colle les graphs


## questions de compréhension:

### Partie 1:
1.d) En cas d’échec lors de la réservation (lignes à NULL), on désalloue les lignes à partir de l’indice (atteint -1) puis la matrice complète.
coef --> 	
[ [ Ligne 0 ] ] --> Allouée, à libérer  free(coef[0]).
[ [ Ligne 1 ] ] --> Allouée, à libérer  free(coef[1]).
[ NULL ] <-- ÉCHEC à i = 2 rien alloué, arrêt de la boucle.
[ ? ] <-- Non atteinte.

Q3.1) Passer une matrice par valeur réalise une copie superficielle (le pointeur coef est dupliqué, pointant vers la même mémoire), ce qui rend les responsabilités de libération floues et empêche de remonter les erreurs. Par ailleurs, *free()* prend en paramètre une adresse.

Q3.2) Il faut N+1 appels à *calloc* et *free->* un par ligne et le dernier pour la matrice elle-même. Si la k-ième allocation échoue, les lignes après k ne sont pas allouées (donc null). Il faut donc libérer les lignes avant k, et la matrice elle-même donc (k-1) +1)) = k appels.

Q3.3) Appeler *free()* deux fois est indéterminé car on ne connaît pas la donnée au deuxième appel (donnée d’un autre programme). Dans *mat_detruire*, on utilise la condition
*(m->coef!=NULL)* pour ne pas appliquer le *free()* deux fois.
Une copie de matrice en C est superficielle, B pointe vers les mêmes champs que A, donc si on libère A, B garde ses pointeurs vers une donnée inconnue, ce qui crée un comportement indéfini.

Q3.4) On effectue l’affectation à la matrice nulle car une fonction qui échoue doit laisser *res à la matrice vide (dont les valeurs sont NULL) et libère les autres données. C’est la règle R3. Cela évite de rappeler *mat_detruire()* sur une donnée inconnue.


### Partie 2:
Q4.1) La fonction *mat_lire()* remplit *tmp*, une variable locale, et non **res* directement : si une erreur survient au milieu du fichier, l’appelant ne recevra jamais une matrice à moitié remplie donc incorrecte, mais bien une matrice nulle.

Q4.2) La lecture ne vérifie pas que chaque ligne de texte correspond à une matrice. Cela n’est pas gênant car on applique le principe “tolérant en lecture, strict en écriture” soit tolérant sur les espaces, tabulations ou sauts de lignes via *scanf*, mais on devient strict pour respecter le format canonique en écriture.

Q4.3) En fin de fonction *mat_lire*, le flux pointe toujours vers le dernier coefficient lu. On peut donc suivre directement sur un autre appel de *mat_lire* sur le flux pour lire séquentiellement une autre matrice.

Q4.4) L’instruction *flush* permet de vider le buffer de la mémoire vers le fichier en écriture. Cela est également effectué par *fclose* mais il est plus juste de faire cette opération manuellement.


### Partie 3:
Q5.1) Le préfixe const évite de modifier l’adresse des attributs de la matrice A lors des calculs, mais pas la valeur des coefficients pointés. Pour protéger les coeffs de A il faudrait passer toutes les lignes *int*** en *const*.

Q5.2) Interdire l’alias *(mat_additionner(&a, &b, &a)* évite de modifier les données de A pendant le calcul en suivant les règles R3 / R5 en cas d’échec.

Q5.3) Pour deux matrices de taille (n,p) et (p,q) il faut n*p*q multiplications d’entiers pour effectuer le produit matriciel. Avec des matrices carrées de taille 1000, il en faut 1000^3 soit 10^9.

Q5.4) Si *(coef(a) + coef(b) > long long)*, on a une erreur de dépassement qui n’est pas repérée par s < a .


### Partie 4:
Q6.1) On découple la gestion des erreurs et de l’affichage. Ainsi main est le programme principal qui peut donc être connecté à une interface graphique logicielle. On rend la bibliothèque indépendante.

Q6.2) Le test de *fclose* en écriture sert à valider que les tampons (buffers) en mémoire ont bien été vidés sur le disque (détection de disque plein), une vérification inutile en lecture car aucun buffer n’est utilisé. 

Q6.3) Dans le scénario 8, si l'enregistrement échoue après un calcul réussi, la matrice R a bien été allouée et il faut donc libérer 3 matrices -> A, B et R. Le *goto nettoyage* s’en charge correctement. 

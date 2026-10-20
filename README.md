# Matrice_C
Tristan JEUILLARD @trijeu --- Nicolas DI GRANDE @Nicolas DG --- TD3

# Compte rendu Implémentation des matrices

## Sommaire
- [Introduction](##Introduction)

## Introduction
Sujet: la création d'une bibliothèque (API) fonctionnelle en code C pour gérer des matrices sous forme textuelle dans des fichiers txt. La finalité est d'obtenir les fonctionnalités de création, lecture, affichage et sauvegarde des matrices tout en gérant les différents cas d'erreur. Ce projet est divisé en modules regroupant les interactions avec le système tel que la gestion en mémoire, le calcul ou les entrées - sorties. L'objectif est de savoir représenter et utiliser une structure similaire à une matrice en langage C, comprendre le principe de lecture écriture à partir d'un flux de données tout en évitant les fuites mémoires, et créer une bibliothèque C avec interfaces, implémentation puis compilation par édition de liens.

Notre avancée est la suivante: Les 4 exercices sont réalisés en intégralité, avec des tests d'utilisations corrects, et aucune fuite mémoire repérée. Ce repository contient par ailleur tout nos codes .h et .c modifiés.

![Description de l'image](images/graphe1.png)

### Règles de propriété de la mémoire retenues
R1 Toute variable Matrice est initialisée à MATRICE_VIDE dès sa déclaration.\
R2 Une fonction qui réussit (MAT_OK) et remplit *res transfère la propriété du résultat à l’appelant, qui devra appeler mat_detruire(&res).\
R3 Une fonction qui échoue laisse *res égal à MATRICE_VIDE et a libéré tout ce qu’elle avait alloué : l’appelant n’a rien à libérer.\
R4 Une fonction ne modifie et ne libère jamais une matrice reçue en entrée (const Matrice *).\
R5 *res est un paramètre de sortie : son ancien contenu est écrasé. S’il possédait de la mémoire, l’appelant doit l’avoir détruite avant l’appel. res doit être distinct des entrées.\
R6 mat_detruire remet la matrice à MATRICE_VIDE : un second appel est sans effet.\
R7 Un fichier est fermé par le code qui l’a ouvert. Les fonctions de matrice_io reçoivent un flux déjà ouvert et ne le ferment jamais.\

## questions de compréhension:

### Partie 1:
1.d) En cas d’échec lors de la réservation (lignes à NULL), on désalloue les lignes à partir de l’indice (atteint -1) puis la matrice complète.
coef -->\	
[ [ Ligne 0 ] ] --> Allouée, à libérer  free(coef[0]).\
[ [ Ligne 1 ] ] --> Allouée, à libérer  free(coef[1]).\
[ NULL ] <-- ÉCHEC à i = 2 rien alloué, arrêt de la boucle.\
[ ? ] <-- Non atteinte.\

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


## Bilan et difficultés
Nous avons compris l'importance de la modularisation afin d'avancer plus vite et en parallèle sur le code.
Lors de notre travail, nous avons travaillés ensemble sur le code depuis l'environnement de Nicolas afin de tout deux avoir une bonne compréhension du sujet et de sa résolution. Nous avons ensuite divisé notre travail sur le compte rendu. Tristan a principalement rédigé le texte en introduction et conclusion, Nicolas a intégré les éléments de code ainsi que les diagrammes de la bibliothèque. Enfin nous avons répondu aux questions de compréhension ensemble pour garder un apprentissage complet sur le projet.
Pour nous aider dans la confection de ce compte rendu, l'IA gemini de google nous a aidé à corriger la  mise en forme sous markdown qui nous était inconnu, ainsi que pour extraire des portions de code qui se situent plus haut. Nous avons prioritisé notre apprentissage en code C et l'usage d'IA à donc été absent pendant la phase de développement.

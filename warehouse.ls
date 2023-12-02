% Automated Warehousing Problem

% The problem is to find a sequence of actions that will deliver all the products to the picking stations. 
% The problem is solved using Answer Set Programming (ASP) and Clingo.

% The problem is solved using the following steps:
% 1. Defining the initial state of the problem.
% 2. Defining the actions that can be performed.
% 3. Defining the constraints on the actions.
% 4. Defining the constraints on the states.
% 5. Defining the effects of the actions.
% 6. Defining the law of inertia.
% 7. Defining the goal state.
% 8. Defining the optimization criteria.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%    DEFINING THE INITIAL STATE  %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The initial state of the problem is defined using the init predicate and is obtained from the init.asp files.

% Parse the init.lp file and determine the count of the number of rows, columns, nodes, shelves, products, picking stations, orders and robots.

% Number of Rows in the grid
noColumns(NR):- NR=#count{X:init(object(node,I),value(at,pair(X,Y)))}.

% Number of Columns in the grid
noRows(NC):- NC=#count{Y:init(object(node,I),value(at,pair(X,Y)))}.

% Number of Nodes
noNodes(ND):- ND=#count{I:init(object(node,I),value(at,pair(X,Y)))}.

% Number of Shelves
noShelves(ND):- ND=#count{I:init(object(shelf,I),value(at,pair(X,Y)))}.

% Number of Products
noProducts(ND):- ND=#count{I:init(object(product,I),value(on,pair(X,Y)))}.

% Number of Picking Stations
noPickingStation(ND):- ND=#count{I:init(object(pickingStation,I),value(at,pair(X,Y)))}.

% Number of Orders
noOrders(ND):- ND=#count{I:init(object(order,I),value(pickingStation,J))}.

% Number of Robots
noRobots(ND):- ND=#count{I:init(object(robot,I),value(at,pair(X,Y)))}.

% Defining the domain of the problem.
% The domain of the problem is defined using the following predicates:

% 1. nodeLoc(NDI, pair(X,Y)) - Node with node id NDI is at the location (X,Y).
nodeLoc(NDI,pair(X,Y)):- init(object(node,NDI),value(at,pair(X,Y))).

% (X,Y) is a valid location in the grid.
pair(X,Y):- init(object(node,NDI),value(at,pair(X,Y))).

% Node with node id NDI is a valid node in the grid.
node(NDI):- init(object(node,NDI),value(at,pair(X,Y))).

% 2. highway(NDI) - Node with node id NDI is a highway.
highway(NDI):- init(object(highway,NDI),value(at,pair(X,Y))).

% 3. pickingStationLoc(PSI,NDI) - Picking station with picking station id PSI is at the node with node id NDI.
pickingStationLoc(PSI,NDI):- init(object(pickingStation,PSI),value(at,pair(X,Y))), init(object(node,NDI),value(at,pair(X,Y))).
% 4. pickingStation(PSI) - Picking station with picking station id PSI is a valid picking station.
pickingStation(PSI):- init(object(pickingStation,PSI),value(at,pair(X,Y))), init(object(node,NDI),value(at,pair(X,Y))).

% 5. robotLoc(RI,NDI,T) - Robot with robot id RI is at the node with node id NDI at time T.
robotLoc(RI,object(node,ND),0):- init(object(robot,RI),value(at,pair(X,Y))), nodeLoc(ND,pair(X,Y)).
% 6. robot(RI) - Robot with robot id RI is a valid robot.
robot(RI):- init(object(robot,RI),value(at,pair(X,Y))).

% 7. shelfLoc(SI,NDI,T) - Shelf with shelf id SI is on the node with node id NDI at time T.
shelfLoc(SI,object(node,ND),0):- init(object(shelf,SI),value(at,pair(X,Y))), nodeLoc(ND,pair(X,Y)).
% 8. shelf(SI) - Shelf with shelf id SI is a valid shelf.
shelf(SI):- init(object(shelf,SI),value(at,pair(X,Y))).

% 9. productLoc(PRI,SI,with(quantity,PQ),T) - Product with product id PRI is on the shelf with shelf id SI with quantity PQ at time T.
productLoc(PRI,object(shelf,SI),with(quantity,PQ),0):- init(object(product,PRI),value(on,pair(SI,PQ))).
% 10. product(PRI) - Product with product id PRI is a valid product.
product(PRI):- init(object(product,PRI),value(on,pair(SI,PQ))).

% 11. orderAt(OI,NDI,contains(PRI,PQ),T) - Order with order id OI is at the node with node id NDI and contains product with product id PRI with quantity PQ at time T.
orderAt(OI,object(node,ND),contains(PRI,PQ),0):- init(object(order,OI),value(pickingStation,PKI)), pickingStationLoc(PKI,ND), init(object(order,OI),value(line,pair(PRI,PQ))).
% 12. order(OI) - Order with order id OI is a valid order.
order(OI):- init(object(order,OI),value(pickingStation,PKI)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%    DEFINING THE ACTIONS   %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Defining all possible movements of the robot.
move(0,1;0,-1;-1,0;1,0).

% Defining all possible actions that can be performed by the robot.
% 1. robotMove(R,move(DX,DY),T) - Robot with robot id R moves in the direction (DX,DY) at time T.
{robotMove(R,move(DX,DY),T):move(DX,DY)}1:- R=1..NR, noRobots(NR), T=0..TN,TN=n-1.

% 2. pickUpShelf(R,SI,T) - Robot with robot id R picks up the shelf with shelf id SI at time T.
{pickUpShelf(R,SI,T):shelf(SI)}1:- R=1..NR, noRobots(NR), T=0..TN,TN=n-1.

% 3. putDownShelf(R,SI,T) - Robot with robot id R puts down the shelf with shelf id SI at time T.
{putDownShelf(R,SI,T):shelf(SI)}1:- R=1..NR, noRobots(NR), T=0..TN,TN=n-1.

% 4. deliver(R,OI,with(SI,PR,DQ),T) - Robot with robot id R delivers the product with product id PR from the shelf with shelf id SI to the picking station with picking station id OI with quantity DQ at time T.
{deliver(R,OI,with(SI,PR,DQ),T):orderAt(OI,object(node,ND),contains(PR,OQ),T), productLoc(PR,object(shelf,SI),with(quantity,PQ),T), DQ=1..PQ}1 :- R=1..NR, noRobots(NR), T=0..TN,TN=n-1.

% The following predicate defines the occurrence of an action. 
% occurs(O,A,T) - Robot performs Action A at time T.
occurs(object(robot,R),move(X,Y),T) :- robotMove(R,move(X,Y),T).
occurs(object(robot,R),pickup,T) :- pickUpShelf(R,_,T).
occurs(object(robot,R),putdown,T) :- putDownShelf(R,_,T).
occurs(object(robot,R),deliver(OI,PRI,DQ),T) :- deliver(R,OI,with(SI,PRI,DQ),T).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%    ACTION CONSTRAINTS     %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Two actions cannot occur at the same time
:- occurs(object(robot,R),A1,T), occurs(object(robot,R),A2,T), A1!=A2.

% Constraints on the movement of the robot
% Robot cannot move outside of the grid
:- robotLoc(RI,object(node,ND),T), robotMove(R,move(X1,Y1),T), nodeLoc(ND,pair(X,Y)), X+X1<1.
:- robotLoc(RI,object(node,ND),T), robotMove(R,move(X1,Y1),T), nodeLoc(ND,pair(X,Y)), Y+Y1<1.
:- robotLoc(RI,object(node,ND),T), robotMove(R,move(X1,Y1),T), nodeLoc(ND,pair(X,Y)), X+X1>NC, noColumns(NC).
:- robotLoc(RI,object(node,ND),T), robotMove(R,move(X1,Y1),T), nodeLoc(ND,pair(X,Y)), Y+Y1>NR, noRows(NR).


% Constraints on picking up of the shelf
% A shelf cant be picked up by 2 robots
:- 2{pickUpShelf(R,S,T): robot(R)}, shelf(S).

% A robot cannot pickup a shelf if it already has one.
:- pickUpShelf(RI,S1,T), shelfLoc(S2,object(robot,RI),T).

% A robot cannot pickup a shelf a shelf is already on a robot
:- pickUpShelf(R1,S,T), shelfLoc(S,object(robot,R2),T).

% A robot can pick up shelf only if it is on the node containing that shelf
:- pickUpShelf(RI,S,T), shelfLoc(S,object(node,ND),T), not robotLoc(RI,object(node,ND),T). 


% Constraints on putting down of the shelf

% A shelf cant be putDown by 2 robots
:- 2{putDownShelf(R,S,T): robot(R)}, shelf(S).

% A robot can put down a shelf only if it has one.
:- putDownShelf(RI,S,T), not shelfLoc(S,object(robot,RI),T).

% A robot cannot putdown a shelf on a highway
:- putDownShelf(RI,S,T), robotLoc(RI,object(node,ND),T), highway(ND). 


% Constraints on delivery of the product

% Can only deliver if robot is on picking station
:- deliver(R,OI,with(_,PR,_),T), orderAt(OI,object(node,ND),contains(PR,_),T), not robotLoc(R,object(node, ND),T).

% Can only deliver if robot has the shelf containing product
:- deliver(R,OI,with(SI,PR,_),T), productLoc(PR,object(shelf,SI),with(quantity,_),T), not shelfLoc(SI,object(robot,R),T).

% Cannot deliver more quantities than the order.
:- deliver(R,OI,with(SI,PR,DQ),T), orderAt(OI,object(node,ND),contains(PR,OQ),T), DQ>OQ.

% Cannot deliver more quantities than the product.
:- deliver(R,OI,with(SI,PR,DQ),T), productLoc(PR,object(shelf,SI),with(quantity,PQ),T), DQ>PQ.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%   CONSTRAINTS ON STATE    %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Picking Station cannot be a highway
:- pickingStationLoc(_,NDI), highway(NDI).

% Shelf cannot be on a highway.
:- shelfLoc(S,object(node,NDI),_), highway(NDI).

% A robot cannot be on two different nodes at the same time
:- 2{robotLoc(R,object(node,ND),T):node(ND)}, robot(R), T=0..n.

% Two robots cannot be on the same node.
:- 2{robotLoc(R,object(node,ND),T):robot(R)}, node(ND), T=0..n.

% Two robots cannot swap their positions at the same time step.
:- robotLoc(R1,object(node,ND1),T), robotLoc(R1,object(node,ND2),T+1), robotLoc(R2,object(node,ND2),T), robotLoc(R2,object(node,ND1),T+1), R1!=R2.

% A shelf cannot be on two different robots at the same time
:- 2{shelfLoc(S,object(robot,NR),T): robot(NR)}, shelf(S), T=0..n.

% Two shelves cannot be on the same robot.
:- 2{shelfLoc(S,object(robot,NR),T): shelf(S)}, robot(NR), T=0..n.

% A shelf cannot be on two different nodes at the same time
:- 2{shelfLoc(S,object(node,ND),T): node(ND)}, shelf(S), T=0..n.

% Two shelves cannot be on the same node.
:- 2{shelfLoc(S,object(node,ND),T): shelf(S)}, node(ND), T=0..n.

% A shelf cannot be on two different shelves at the same time.
:- shelfLoc(S,object(node,_),T), shelfLoc(S,object(robot,_),T).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% EFFECTS OF ACTIONS %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Effect of moving the robot in a direction (DX,DY) at time T. 
robotLoc(R,object(node,NEW_ND),T+1):- robotLoc(R,object(node,ND),T), nodeLoc(ND,pair(X,Y)), nodeLoc(NEW_ND, pair(X+DX,Y+DY)), robotMove(R,move(DX,DY),T).

% Effect of a robot picking up a shelf at time T.
shelfLoc(S,object(robot,RI),T+1):- pickUpShelf(RI,S,T), shelfLoc(S,object(node,ND),T), robotLoc(RI,object(node,ND),T).

% Effect of a robot putting down a shelf at time T.
shelfLoc(S,object(node,ND),T+1):- putDownShelf(RI,S,T), shelfLoc(S,object(robot,RI),T), robotLoc(RI,object(node,ND),T).

% Effect of a robot delivering a product at time T.
orderAt(OI,object(node,ND),contains(PR,OU-DQ),T+1):- deliver(R,OI,with(SI,PR,DQ),T), orderAt(OI,object(node,ND),contains(PR,OU),T).
productLoc(PR,object(shelf,SI),with(quantity,PQ-DQ),T+1):- deliver(R,OI,with(SI,PR,DQ),T), productLoc(PR,object(shelf,SI),with(quantity,PQ),T).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%      LAW OF INERTIA       %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Law of inertia
% The law of inertia states that if an action does not occur at time T, then the state of the system at time T+1 is the same as the state of the system at time T.
% The law of inertia is defined using the following predicates:

robotLoc(R,object(node,ND),T+1):- robotLoc(R,object(node,ND),T), not robotMove(R,move(_,_),T), T<n.
shelfLoc(S,object(node,ND),T+1):-shelfLoc(S,object(node,ND),T), not pickUpShelf(_,S,T), T<n.
shelfLoc(S,object(robot,RI),T+1):-shelfLoc(S,object(robot,RI),T), not putDownShelf(RI,S,T), T<n.
orderAt(OI,object(node,ND),contains(PR,OU),T+1):- orderAt(OI,object(node,ND),contains(PR,OU),T), productLoc(PR,object(shelf,SI),with(quantity,PQ),T), not deliver(_,OI,with(SI,PR,_),T), T<n.
productLoc(PR,object(shelf,SI),with(quantity,PQ),T+1):- productLoc(PR,object(shelf,SI),with(quantity,PQ),T), not deliver(_,_,with(SI,PR,_),T), T<n.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%      GOAL STATE       %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- not orderAt(OI,object(node,_),contains(PR,0),n), orderAt(OI,object(node,_),contains(PR,_),0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%    OPTIMIZATION CRITERIA  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The optimization criteria is to minimize the number of actions performed by the robot.

% Count the number of actions required to solve the problem.
totalActions(N):-N=#sum{1,O,A,T:occurs(O,A,T)}.

% Calculate the time taken to solve the problem.
totalTime(N-1):-N=#count{T:occurs(O,A,T)}.

% Minimize the number of actions performed by the robot.
#minimize{1,O,A,T:occurs(O,A,T)}.

% Minimize the time taken to solve the problem.
#minimize{T:occurs(O,A,T)}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%    SHOWING THE OUTPUT     %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#show occurs/3.
#show totalActions/1.
#show totalTime/1.
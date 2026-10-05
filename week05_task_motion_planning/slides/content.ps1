# Slide content and speaker guidance. Code excerpts are validated against authored PDDL.
$sources=@{
 pddl='https://www.cs.cmu.edu/~mmv/planning/readings/98aips-PDDL.pdf'
 search='https://lavalle.pl/planning/ch2.pdf'
 pyperplan='https://github.com/aibasel/pyperplan'
 tamp='https://arxiv.org/abs/2010.01083'
 demo='Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md.'
}
$snippets=@{
 predicate=@{file='domain.pddl';code='(robot-at ?l - location)'}
 fact=@{file='problem.pddl';code='(robot-at delivery)'}
 types=@{file='domain.pddl';code='(:types location package)'}
 objects=@{file='problem.pddl';code=@'
(:objects pickup delivery
          upper-left upper-right - location
          parcel - package)
'@}
 init=@{file='problem.pddl';code=@'
(:init
  (robot-at delivery)
  (package-at parcel pickup)
  (hand-empty)
'@}
 goal=@{file='problem.pddl';code='(:goal (package-at parcel delivery))'}
 pickhead=@{file='domain.pddl';code=@'
(:action pick
  :parameters (?p - package ?l - location)
  :precondition (and
    (robot-at ?l)
    (package-at ?p ?l)
    (hand-empty))
'@}
 pickeffect=@{file='domain.pddl';code=@'
:effect (and
  (holding ?p)
  (not (package-at ?p ?l))
  (not (hand-empty)))
'@}
 loadedpre=@{file='domain.pddl';code=@'
:precondition (and
  (robot-at ?from)
  (holding ?p)
  (can-loaded ?from ?to))
'@}
 moveeffect=@{file='domain.pddl';code=@'
:effect (and
  (not (robot-at ?from))
  (robot-at ?to))
'@}
 permission=@{file='problem.pddl';code='(can-loaded pickup delivery)'}
 emptypermission=@{file='problem.pddl';code='(can-empty pickup delivery)'}
 reversepermission=@{file='problem.pddl';code='(can-loaded delivery pickup)'}
 place=@{file='domain.pddl';code=@'
(:action place
  :parameters (?p - package ?l - location)
  :precondition (and (robot-at ?l) (holding ?p))
  :effect (and
    (package-at ?p ?l)
    (hand-empty)
    (not (holding ?p))))
'@}
}
$candidate=@('(move-empty delivery pickup)','(pick parcel pickup)','(move-loaded parcel pickup delivery)','(place parcel delivery)')
$revised=@('(move-empty delivery pickup)','(pick parcel pickup)','(move-loaded parcel pickup upper-left)','(move-loaded parcel upper-left upper-right)','(move-loaded parcel upper-right delivery)','(place parcel delivery)')
$lesson=@(
@{title='Classical planning & TAMP';subtitle='Read the task model. Connect it to robot motion.';kind='title';part=0;minutes=0;refs=@('demo');notes=@'
Untimed title. Week 5 has two clearly separated parts: classical planning/PDDL for 20 minutes, then task-and-motion planning for 10. The demo is 10 minutes followed by 5 minutes questions/recap, totaling 45. Students know Python and Weeks 1–4, but PDDL is new. Teach practical reading through this delivery example, without requirement flags, dialects or advanced syntax. All 14 original Week 5 files were reviewed, including three saved figures. Preserve all 12 demo files and teaching notes. No separate professor presentation was supplied. Slides provide more explanation than previous weeks; code is short, editable and tied to actual source. This is a Python-only demo; no ROS/Gazebo process is needed.
'@},
@{title='Part 1 · Classical planning & PDDL';subtitle='What should the robot do, and in what order?';kind='part1';part=1;minutes=.5;refs=@('search','demo');notes=@'
Make the boundary explicit: first learn a symbolic task model and how to read its PDDL files. The robot must deliver one parcel. Week 4 chose a geometric route between configurations; now choose the actions that achieve a task. The three learning goals are to read facts, determine when an action applies, and explain how actions change a state. Save geometric rejection for Part 2: at this stage treat connection permissions as symbolic facts. PDDL is a model description language; it is not itself a search algorithm or robot controller.
'@},
@{title='What is classical planning?';subtitle='Find an action sequence that makes the goal true.';kind='classical';part=1;minutes=1.5;refs=@('search','demo');notes=@'
Visual: initial state → applicable actions → goal. A planning problem supplies the initial state, available action rules and goal conditions; the planner chooses a sequence. Here the initial state is fully known, action outcomes are deterministic, and actions are discrete transitions. This does not mean the physical robot has no continuous position; the task model abstracts it to named locations. Example sequence: travel empty to pickup, pick, travel while holding, place. A goal specifies what should become true, rather than prescribing that sequence. Contrast model, planner and eventual execution; no sensing uncertainty or dynamics is modeled here. Briefly connect Week 6 to relaxing these assumptions.
'@},
@{title='States, predicates, and facts';subtitle='A state is the collection of facts that are true now.';kind='facts';part=1;minutes=1.5;refs=@('pddl','demo');notes=@'
Show the actual predicate declaration (robot-at ?l - location) and the initial grounded fact (robot-at delivery). A predicate names a relationship that can be true or false after objects fill its arguments. A grounded fact has no free variables. These are statements, not Python functions that command the robot or compute coordinates. The state also includes (package-at parcel pickup) and (hand-empty), plus connection permissions. Explain each in ordinary English; robot-at names one location, package-at relates package and location, holding records possession, and hand-empty has no arguments. The slide lists selected facts for readability, not the entire initial state.
'@},
@{title='Goals and the closed-world model';subtitle='Say what must be true; let the planner choose the actions.';kind='goal';part=1;minutes=1.5;refs=@('search','demo');notes=@'
Use the actual goal (package-at parcel delivery). It requests delivery of the package; it does not explicitly require hand-empty or robot-at delivery, though the available place action produces those facts in this demo. Under the classical closed-world model, facts absent from a state are false, not unknown. Initially holding(parcel) is false; after picking package-at(parcel,pickup) is false. This is a modeling assumption, not a claim that real robot sensing is complete. Explain that a final state may contain additional facts beyond the goal. Ask whether specifying the goal means that the planner has already chosen the route: no.
'@},
@{title='PDDL: domain versus problem';subtitle='Planning Domain Definition Language describes the model.';kind='domain';part=1;minutes=1;refs=@('pddl','demo');notes=@'
Compare two editable cards. domain.pddl defines the reusable delivery vocabulary and four action schemas. problem.pddl names the objects, initial facts and goal for this delivery instance. Changing the parcel location or goal usually changes the problem; changing pickup rules changes the domain. The problem links to the domain named delivery. Pyperplan is the tool that reads the descriptions and searches. Focus on where students should look for a fact or rule. Do not explain language feature declarations or variants. Mention file names explicitly so the upcoming code walkthrough is easy to navigate.
'@},
@{title='Objects, types, and variables';subtitle='Read the names and placeholders in the demo files.';kind='objects';part=1;minutes=1.5;refs=@('pddl','demo');notes=@'
Show the exact types and objects declarations, with whitespace rewrapped. pickup, delivery, upper-left and upper-right are concrete location objects; parcel is a concrete package object. A type groups objects eligible for a parameter. In a declaration, the hyphen associates preceding names with a type; it is not subtraction. ?p and ?l are variables/placeholders, conventionally package and location here, not special reserved variable names. They receive actual objects when an action is grounded. Keep the explanation practical: students should be able to read ?p - package and identify parcel as a compatible substitution. The robot is implicit in the predicates and is not a declared robot object in this domain.
'@},
@{title='Read the initial state and goal';subtitle='Connect symbolic facts to the delivery scene.';kind='initial';part=1;minutes=1.5;refs=@('demo');notes=@'
Show an explicitly labeled opening excerpt of :init, not a complete section: the connection permission facts follow in the real file. The robot starts at delivery (5,3); parcel starts at pickup (1,3); hand is empty. The goal is the package at delivery. Coordinates and walls live in scene.json, not in these PDDL facts. Initial permissions can-empty/can-loaded are optimistic allowed directed connections for each load mode; they are not results of collision checking. The domain supplies the rules interpreting these facts. The editable scene shows named waypoints and walls, preserving the exact geometry, but avoid revealing the revised route before Part 2.
'@},
@{title='Anatomy of an action';subtitle='Parameters identify objects; conditions and effects define behavior.';kind='anatomy';part=1;minutes=1.5;refs=@('pddl','demo');notes=@'
Present parameters, preconditions and effects as three distinct fields. Parameters are the placeholders; preconditions must hold before the action; effects describe the successor state after completion. The domain defines move-empty, move-loaded, pick and place. Explain their purposes without showing all four definitions at once. An action schema is reusable, while an action instance has concrete objects. Preconditions are tests, not facts the action creates; effects are updates, not tests. The model has no numerical travel time or distance cost in PDDL. Python animation later supplies illustrative timing rather than changing these task rules.
'@},
@{title='When can we pick?';subtitle='All three preconditions must hold before pickup.';kind='pick';part=1;minutes=2;refs=@('pddl','demo');notes=@'
Read the actual opening of pick. The two parameters are a package ?p and a location ?l. The and combines three facts: robot at ?l, package ?p at ?l, hand empty. With ?p=parcel and ?l=pickup, pick is initially inapplicable because the robot is at delivery. After move-empty delivery pickup, all three become true. An applicable symbolic action has satisfied these listed conditions; physical handling feasibility is checked separately in Part 2. Parentheses delimit expressions and arguments, not arithmetic. Point to each code line and ask students to translate it into English before explaining effects on the next slide.
'@},
@{title='What changes after picking?';subtitle='Add some facts, remove others, preserve everything else.';kind='effects';part=1;minutes=2.5;refs=@('pddl','demo');notes=@'
Use the actual pick effect fragment. Add (holding parcel); delete (package-at parcel pickup) and (hand-empty). Here not in an effect means the fact becomes false, so it is removed from the set of true facts. The robot-at pickup fact persists because it is untouched. Connection permissions also persist, omitted from the selected before/after facts. The before state shown is after the empty journey to pickup, not the original initial state. Explain the frame assumption: effects enumerate changes, so other facts are carried forward. The package has no package-at fact while held; its location is represented by possession plus robot geometry. Place restores package-at and hand-empty and removes holding. The backup provides its complete short action.
'@},
@{title='Read a loaded move';subtitle='The robot changes location while possession stays true.';kind='loaded';part=1;minutes=1.5;refs=@('pddl','demo');notes=@'
Read move-loaded preconditions and the location effect fragments. Its parameters include the held package and source/destination locations. Require robot-at source, holding package, and can-loaded source destination. Delete robot-at source and add robot-at destination. Holding persists without repetition in the effects. This is not the same action as move-empty, whose preconditions require hand-empty and can-empty. Permission is directed, and optimistic permission alone says nothing about geometric clearance. The package is not assigned a package-at location during a loaded move; holding remains the symbolic representation until place. Both fragments come from the actual move-loaded definition and remain labeled as excerpts.
'@},
@{title='From variables to a concrete action';subtitle='Grounding fills placeholders; applicability checks the current facts.';kind='grounding';part=1;minutes=1.5;refs=@('pyperplan','demo');notes=@'
Show (pick ?p ?l) → (pick parcel pickup), labeled schema pattern and grounded instance. Substitute the same objects consistently into all conditions and effects, not just the action name. Grounding generates type-compatible action instances; it does not mean every instance can execute in the current state. pick(parcel,pickup) exists but fails initial preconditions; it becomes applicable after the empty move. Pyperplan parses the authored files and creates grounded operators. Python subsequently uses those operators' applicable() and apply() methods, so there is no second hand-written symbolic rule system. Avoid advanced grounding optimizations or language grammar.
'@},
@{title='Search symbolic states';subtitle='BFS chooses a shortest action sequence in this task model.';kind='search';part=1;minutes=2;refs=@('pyperplan','search','demo');notes=@'
Show the exact four-action candidate with a simple state chain. Initial → move-empty delivery pickup → pick parcel pickup → move-loaded parcel pickup delivery → place parcel delivery. The hypothetical final state satisfies the package goal under the symbolic rules. Nodes here are fact sets; edges are applicable grounded actions. Pyperplan BFS explores by number of actions; all actions have unit search cost, so the result minimizes action count in the discrete model, not metres or time. The local code sorts grounded operators for deterministic tie-breaking. PDDL describes transitions while BFS performs search. This is a candidate, not yet geometrically validated or executed. End Part 1 by asking whether symbolic validity guarantees the robot fits.
'@},
@{title='Part 2 · Task and motion planning';subtitle='Can the symbolic decisions be realized by robot motion?';kind='part2';part=2;minutes=.5;refs=@('tamp','demo');notes=@'
Make a clear cut. Students can now read the task model; next integrate its discrete decisions with geometric feasibility. Expand TAMP as Task and Motion Planning. The symbolic candidate will meet a geometric constraint absent from its optimistic permissions. Integration includes feedback and revised task decisions, not just computing a task plan once and blindly executing it. This demo supplies a small finite set of candidate straight motions; general TAMP can search configurations, grasps, placements and continuous paths as well.
'@},
@{title='What does TAMP connect?';subtitle='Task decisions and geometric feasibility inform each other.';kind='connect';part=2;minutes=1;refs=@('tamp','demo');notes=@'
Visual: task facts and action choices ↔ poses, footprints and motions. Named locations map to scene.json coordinates; holding changes the disk radius. A task action such as move-loaded needs a feasible geometric realization, and failure can change the discrete plan. Relate Week 4's PRM to a possible low-level motion-feasibility component in a larger TAMP pipeline. This demo does not invoke PRM or reuse the arm; its delivery robot is a disk and its designated motions are straight segments checked analytically against rectangles. The same separation of task decisions and valid physical motion remains useful. TAMP means coordinating the choices across those levels.
'@},
@{title='A symbolic plan can fail geometrically';subtitle='A permitted connection is not a collision certificate.';kind='failure';part=2;minutes=1.5;refs=@('demo');notes=@'
Show the four candidate actions with the third highlighted, beside the exact scene's shortcut. The empty outward trip fits; pick increases the footprint; the loaded return is then blocked. Hypothetical validation replays parsed operators in immutable temporary states, checks each motion or footprint change, and does not modify execution state. The rejected action is move-loaded parcel pickup delivery, zero-based index 2 in Python. State that the preview at pickup with the parcel held is hypothetical, not already executed motion. The initial symbolic model omitted the load-dependent geometric constraint even though all its preconditions held.
'@},
@{title='Empty fits; loaded does not';subtitle='The footprint changes when the robot holds the parcel.';kind='footprints';part=2;minutes=1.5;refs=@('demo');notes=@'
Editable close-up of the passage, with the empty and loaded disks in separate panels. Walls end at y=2.8 and begin at y=3.2, giving 0.40 m gap. Centerline y=3 has 0.20 m clearance to each wall. Empty radius 0.12 (diameter 0.24) fits; loaded radius 0.25 (diameter 0.50) does not. Contact is collision. The checker tests the whole swept disk along each straight segment against the rectangles and keeps the disk strictly within the 6×6 m workspace. It also checks the larger before/after footprint at pick/place, so growing at pickup must be safe. Package handling is abstract possession plus enlarged disk, without grasp mechanics or manipulation physics.
'@},
@{title='The task-and-motion loop';subtitle='Use geometric feedback to refine the symbolic candidate.';kind='loop';part=2;minutes=2;refs=@('tamp','demo');notes=@'
Visual loop: symbolic search → candidate → geometric check; failed motion → refine permission → symbolic search; all checks pass → validated execution. Explain solve(), validate_plan() and refine_problem() in planning.py, without a long Python listing. The original authored PDDL problem remains unchanged. Revised initial permission facts are assembled in temporary storage and parsed again; every attempt restarts from the original robot/package/hand state under the refined permission model. Candidate checking is hypothetical. This makes task choices respond to geometry, rather than asserting that one geometric failure globally invalidates an action schema. Handling failures with no removable motion permission are reported separately.
'@},
@{title='Refine precisely';subtitle='Reject one directed connection for one load state.';kind='refine';part=2;minutes=1;refs=@('demo');notes=@'
Show actual permission facts as editable code. Remove only (can-loaded pickup delivery). Keep (can-empty pickup delivery) and (can-loaded delivery pickup). The forward loaded shortcut is invalid under this scene and designated centerline; the demo does not automatically infer or remove the reverse permission, even though the same straight geometry is symmetric. If later queried, that reverse motion would be checked too. Neither the whole move-loaded schema nor every route between pickup/delivery is rejected. A different continuous path could exist between those names; here the supplied upper waypoint connections provide the alternative. Replanning refines a problem copy, not the authored source file or execution state.
'@},
@{title='The revised six-action plan';subtitle='Keep the empty shortcut; carry the parcel along the upper route.';kind='revised';part=2;minutes=1.5;refs=@('demo');notes=@'
Show the exact six actions and numbered geometric route. Empty delivery→pickup, pick, loaded pickup→upper-left→upper-right→delivery, place. Upper coordinates are (2,5.4) and (4,5.4), above the wall top 4.8; the loaded disk fits the straight connections and workspace. This candidate has passed every designated motion and footprint-change check before playback. Initial empty segment is unchanged. Six actions is the shortest BFS sequence in the refined symbolic model, not a claim of minimum continuous distance. The goal becomes true only after place finishes. Use the actual saved validated-plan image as a fallback, but build the main diagram from editable shapes.
'@},
@{title='Planning, validation, and execution';subtitle='A candidate, a checked plan, and an executed result are different.';kind='stages';part=2;minutes=1;refs=@('demo');notes=@'
Three cards: propose actions, check hypothetically, animate validated actions. At the rejection stage, execution has not started, even though the display previews a held parcel. A checked plan can be displayed before any real animation begins. During execution, the disk's continuous pose changes while robot-at still names the departure waypoint until the action completes. Parsed effects update symbolic facts at completion; pick/place change possession and radius. The package follows the robot only when held. Animation uses 1 m/s moves with a minimum 0.6-second action duration and 0.6-second handling pauses; this is illustrative kinematic timing, not dynamics or a hardware safety guarantee.
'@},
@{title='Demo: predict, reject, revise, execute';subtitle='Watch the facts, footprint, and action sequence together.';kind='demo';part=0;minutes=15;refs=@('demo');notes=@'
10 MINUTES DEMO: 2 minutes inspect initial facts and the four-action candidate; ask which action will fail. 3 minutes reveal the hypothetical rejection and exact removed permission; confirm the empty permission remains. 3 minutes inspect the revised six-action plan and press Play at the execution stage. 2 minutes pause after pick, inspect holding and enlarged radius/package attachment, then complete delivery. No ROS or Gazebo process is needed. Stages reveal results computed at startup, not replanning triggered by Next stage. Reset returns to the initial state and display; playback after completion replays the validated plan.
5 MINUTES QUESTIONS/RECAP: ask domain versus problem; preconditions versus effects; why an unchanged fact persists; whether symbolic validity guarantees motion feasibility; why only one directed/load-specific permission changes. Ask whether the hypothetical preview means execution already occurred: no. Distinguish symbolic-failure (no plan with remaining designated connections) from geometric-failure. Optional command: python week05_task_motion_planning/demo/demo.py --headless. Keep rejected.png, overview.png and delivered.png ready as fallbacks. Local slide checks are separate from Python/GUI/classroom rehearsal.
'@},
@{title='Reading place';subtitle='The parcel becomes located again when it is released.';kind='place';part=0;minutes=0;backup=$true;refs=@('demo');notes=@'
Untimed backup. Full short place action from domain.pddl. Parameters package/location; require robot at the location and holding the package. Add package-at at that location and hand-empty; delete holding. Robot location persists. Ground with parcel and delivery to achieve the actual goal. Vocabulary: parameters are placeholders, preconditions are required facts, effects are fact changes, and not inside effects removes a fact. Explain by tracing the last action, rather than teaching a formal grammar. The entire action fits as editable code, with its final closing parentheses preserved.
'@},
@{title='State updates and symbolic search';subtitle='Ground the action, check its conditions, then update the facts.';kind='state_backup';part=0;minutes=0;backup=$true;refs=@('search','pyperplan','demo');notes=@'
Untimed backup. For an applicable action, S_next=(S minus Delete) union Add. Its preconditions must be contained in the current state. Example after the empty journey: robot-at pickup, package-at parcel pickup, hand-empty, unchanged permissions. Pick yields robot-at pickup, holding parcel, unchanged permissions. This set update is what parsed operators encode. Grounding substitutes typed objects consistently; applicability depends on the current facts, not just valid types. BFS explores the symbolic graph by depth, skipping revisited states. In this demo all action costs are one, so the shortest action count is found; it is unrelated to Euclidean travel cost or Week 4's joint-space edge length. No Python duplication of the PDDL rules exists in the demo.
'@},
@{title='Swept-disk geometry';subtitle='Check the entire designated straight motion against each wall.';kind='geometry_backup';part=0;minutes=0;backup=$true;refs=@('demo');notes=@'
Untimed backup. For a straight center segment from a to b and obstacle rectangle O, clearance is the minimum distance from any center along the segment to O. Require distance > disk radius, with 1e-12 collision tolerance. Segment intersection gives distance zero; otherwise the implementation compares endpoint-to-rectangle and corner-to-segment distances. For the central shortcut, minimum distance is 0.20 m: empty passes at 0.12, tangent radius 0.20 fails, loaded radius 0.25 fails. Convex workspace containment follows from both endpoints strictly inside the box shrunk by radius. Pick/place use the maximum before/after radius at the same point. This whole-segment calculation applies to static axis-aligned rectangles and disks; it is not a general robot collision library or sampled PRM edge validation.
'@},
@{title='Failure meanings and broader TAMP';subtitle='A finite task-and-motion model has specific limits.';kind='limits';part=0;minutes=0;backup=$true;refs=@('tamp','demo');notes=@'
Untimed backup. Sixteen initial directed/load-specific permissions give at most seventeen candidate searches: each rejected motion removes a new permission. Repeated rejection without progress raises an error; no remaining symbolic route returns symbolic-failure. A failed initial/handling footprint has no motion permission to remove and returns geometric-failure. These messages do not prove there is no continuous route or grasp in a larger model. The finite scene provides designated waypoints and straight connections, abstract package handling and disk footprints. General TAMP may search grasps, placements, IK/configurations and continuous motions, and may use a planner such as PRM for some geometric queries. Reconsider stored feasibility if the scene, footprint or candidate motion changes. No manipulation physics, uncertainty or controller-ready trajectories are modeled.
'@}
)

(define (domain delivery)
  (:requirements :strips :typing)
  (:types location package)
  (:predicates
    (robot-at ?l - location)
    (package-at ?p - package ?l - location)
    (holding ?p - package)
    (hand-empty)
    (can-empty ?from ?to - location)
    (can-loaded ?from ?to - location))

  (:action move-empty
    :parameters (?from ?to - location)
    :precondition (and (robot-at ?from) (hand-empty) (can-empty ?from ?to))
    :effect (and (not (robot-at ?from)) (robot-at ?to)))

  (:action move-loaded
    :parameters (?p - package ?from ?to - location)
    :precondition (and (robot-at ?from) (holding ?p) (can-loaded ?from ?to))
    :effect (and (not (robot-at ?from)) (robot-at ?to)))

  (:action pick
    :parameters (?p - package ?l - location)
    :precondition (and (robot-at ?l) (package-at ?p ?l) (hand-empty))
    :effect (and (holding ?p) (not (package-at ?p ?l)) (not (hand-empty))))

  (:action place
    :parameters (?p - package ?l - location)
    :precondition (and (robot-at ?l) (holding ?p))
    :effect (and (package-at ?p ?l) (hand-empty) (not (holding ?p))))
)

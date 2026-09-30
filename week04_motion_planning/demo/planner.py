"""Readable PRM: rejection sampling, k-nearest connections, then Dijkstra."""
from dataclasses import dataclass
import heapq
import math
import random
import time

from robot import LIMIT, configuration_free, edge_free, validate


@dataclass
class Roadmap:
    points: list
    adjacency: list
    neighbors: int
    attempts: int = 0
    seconds: float = 0.0

    @property
    def edge_count(self):
        return sum(map(len, self.adjacency)) // 2


@dataclass
class QueryResult:
    path: list
    length: float | None
    message: str
    roadmap: Roadmap


def shortest_path(adjacency, start, goal):
    costs, parents, queue = {start: 0.0}, {}, [(0.0, start)]
    while queue:
        distance, node = heapq.heappop(queue)
        if distance != costs[node]:
            continue
        if node == goal:
            path = [goal]
            while path[-1] != start:
                path.append(parents[path[-1]])
            return path[::-1], distance
        for other, weight in adjacency[node]:
            candidate = distance + weight
            if candidate < costs.get(other, math.inf):
                costs[other], parents[other] = candidate, node
                heapq.heappush(queue, (candidate, other))
    return [], None


def nearest(points, q, count, exclude=None):
    return sorted((math.dist(q, p), i) for i, p in enumerate(points)
                  if i != exclude)[:count]


def connect(graph, a, b):
    if a == b or any(i == b for i, _ in graph.adjacency[a]):
        return
    if edge_free(graph.points[a], graph.points[b]):
        weight = math.dist(graph.points[a], graph.points[b])
        graph.adjacency[a].append((b, weight))
        graph.adjacency[b].append((a, weight))


def build_roadmap(samples=300, neighbors=10, seed=7, *, max_attempts=None):
    if type(samples) is not int or samples < 1 or type(neighbors) is not int or neighbors < 1:
        raise ValueError('Samples and neighbors must be positive integers.')
    if type(seed) is not int:
        raise ValueError('Seed must be an integer.')
    limit = samples * 100 if max_attempts is None else max_attempts
    if type(limit) is not int or limit < 1:
        raise ValueError('Attempt limit must be a positive integer.')
    begin = time.perf_counter()
    rng, points, attempts = random.Random(seed), [], 0
    while len(points) < samples and attempts < limit:
        q = (rng.uniform(-LIMIT, LIMIT), rng.uniform(-LIMIT, LIMIT))
        attempts += 1
        if configuration_free(q):
            points.append(q)
    if len(points) < samples:
        raise RuntimeError(f'Sampling limit reached: accepted {len(points)} of {samples}.')
    graph = Roadmap(points, [[] for _ in points], neighbors, attempts)
    examined = set()
    for i, q in enumerate(points):
        for _, j in nearest(points, q, neighbors, exclude=i):
            pair = tuple(sorted((i, j)))
            if pair not in examined:
                examined.add(pair)
                connect(graph, i, j)
    graph.seconds = time.perf_counter() - begin
    return graph


def query_roadmap(roadmap, start, goal):
    start, goal = validate(start), validate(goal)
    if not configuration_free(start) or not configuration_free(goal):
        raise ValueError('Start and goal must both be collision-free, including padding.')
    # Query attachments never change the reusable preprocessing graph.
    graph = Roadmap(list(roadmap.points), [list(row) for row in roadmap.adjacency],
                    roadmap.neighbors, roadmap.attempts, roadmap.seconds)
    if start == goal:
        return QueryResult([start], 0.0, 'Start equals goal.', graph)
    first = len(graph.points)
    graph.points.extend([start, goal])
    graph.adjacency.extend([[], []])
    for i in (first, first+1):
        for _, j in nearest(roadmap.points, graph.points[i], graph.neighbors):
            connect(graph, i, j)
    connect(graph, first, first+1)
    indices, length = shortest_path(graph.adjacency, first, first+1)
    path = [graph.points[i] for i in indices]
    return QueryResult(path, length, 'Path found.' if path else 'No path found in this roadmap.', graph)

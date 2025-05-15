import re
from collections import defaultdict
import sys

class TreeNode:
    def __init__(self, id, label):
        self.id = id
        self.label = label
        self.children = []

    def __eq__(self, other):
        if not isinstance(other, TreeNode):
            return False
        return (self.label == other.label and
                len(self.children) == len(other.children) and
                all(c1 == c2 for c1, c2 in zip(self.children, other.children)))

def parse_dot_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Extract node labels
    label_pattern = re.compile(r'(\d+) \[ label="(.*?)" \];')
    labels = {match[0]: match[1] for match in label_pattern.findall(content)}

    # Extract edges
    edge_pattern = re.compile(r'(\d+) -> (\d+);')
    edges = defaultdict(list)
    for parent, child in edge_pattern.findall(content):
        edges[parent].append(child)

    # Find root (node that is not a child of any other node)
    all_nodes = set(labels.keys())
    child_nodes = {child for children in edges.values() for child in children}
    root_ids = list(all_nodes - child_nodes)
    if len(root_ids) != 1:
        print(len(root_ids))
        raise ValueError("Invalid tree: must have exactly one root.")
    root_id = root_ids[0]

    # Build tree recursively
    def build_tree(node_id):
        node = TreeNode(node_id, labels[node_id])
        for child_id in edges.get(node_id, []):
            node.children.append(build_tree(child_id))
        return node

    return build_tree(root_id)

def compare_trees(file1, file2):
    tree1 = parse_dot_file(file1)
    tree2 = parse_dot_file(file2)
    return tree1 == tree2

# Example usage:
if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python compare_trees.py file1.dot file2.dot")
    else:
        equal = compare_trees(sys.argv[1], sys.argv[2])
        if equal:
            sys.exit(0)
        else:
            sys.exit(1)
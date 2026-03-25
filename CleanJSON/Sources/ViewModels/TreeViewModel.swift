import Foundation
import SwiftUI

class TreeViewModel: ObservableObject {
    @Published var rootNode: JSONNode?
    @Published var selectedNode: JSONNode?
    @Published var expandedNodes: Set<UUID> = []

    func buildTree(from json: Any?) {
        guard let json = json else {
            rootNode = nil
            return
        }

        rootNode = JSONNode.buildTree(from: json)
    }

    func selectNode(_ node: JSONNode) {
        selectedNode = node
    }

    func toggleNode(_ node: JSONNode) {
        node.toggleExpansion()

        if node.isExpanded {
            expandedNodes.insert(node.id)
        } else {
            expandedNodes.remove(node.id)
        }
    }

    func expandAll() {
        guard let root = rootNode else { return }
        expandNodeRecursive(root)
    }

    func collapseAll() {
        guard let root = rootNode else { return }
        collapseNodeRecursive(root)
        expandedNodes.removeAll()
    }

    private func expandNodeRecursive(_ node: JSONNode) {
        if node.hasChildren {
            node.isExpanded = true
            expandedNodes.insert(node.id)

            for child in node.children {
                expandNodeRecursive(child)
            }
        }
    }

    private func collapseNodeRecursive(_ node: JSONNode) {
        node.isExpanded = false

        for child in node.children {
            collapseNodeRecursive(child)
        }
    }

    func getNodePath(_ node: JSONNode) -> String {
        return node.path
    }
}

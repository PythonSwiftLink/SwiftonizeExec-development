//
//  SourceFilesFilter.swift
//  SwiftonizeCLI
//
//  Created by MusicMaker on 14/04/2023.
//

import Foundation
import PathKit
import PyAstParser
import PyAst

enum WrapSource {
    case pyi(path: Path)
    case py(path: Path)
    case both(py: Path, pyi: Path)
    
    
    func swiftFile(_ dst: Path) -> Path {
        switch self {
        case .pyi(let path):
            return dst + "\(path.lastComponentWithoutExtension).swift"
        case .py(let path):
            return dst + "\(path.lastComponentWithoutExtension).swift"
        case .both(_, let pyi):
            return dst + "\(pyi.lastComponentWithoutExtension).swift"
        }
    }
	func jsonFile(_ dst: Path) -> Path {
		switch self {
		case .pyi(let path):
			return dst + "\(path.lastComponentWithoutExtension).json"
		case .py(let path):
			return dst + "\(path.lastComponentWithoutExtension).json"
		case .both(_, let pyi):
			return dst + "\(pyi.lastComponentWithoutExtension).json"
		}
	}
}

class SourceFilter {
    
    var sources: [WrapSource]
    
    init(root: Path) throws {
        
        let pyis = root.filter({$0.extension == "pyi"})
        var pys = root.filter({$0.extension == "py"})
		let jsons = root.filter({ $0.extension == "json" })
		
        sources = []
        for src in pyis {
            let fname = src.lastComponentWithoutExtension
            if let py_index = pys.firstIndex(where: {$0.lastComponentWithoutExtension == fname}) {
                let py = pys[py_index]
                sources.append(.both(py: py, pyi: src))
                pys.remove(at: py_index)
                continue
            }
            sources.append(.pyi(path: src))
            
        }
        for src in pys {
            sources.append(.py(path: src))
        }
		
    }
    
    
}


class SourcePreProcessor {
	
}

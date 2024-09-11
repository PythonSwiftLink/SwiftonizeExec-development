

import Foundation
import Swiftonizer
//import PySwiftCore
import PathKit
import ArgumentParser
//import XcodeEdit
//import PythonResources
extension PathKit.Path: Decodable {
	public init(from decoder: Decoder) throws {
		let c = try decoder.singleValueContainer()
		self.init(try c.decode(String.self))
	}
	var is_json: Bool { self.extension == "json" }
	
}

@main
struct App: AsyncParsableCommand {
	
	static var pythonlib: String? = nil
	static var extra: String? = nil
	
	static var configuration = CommandConfiguration(
		commandName: "swiftonize",
		abstract: "Generate static references for autocompleted resources like images, fonts and localized strings in Swift projects",
		version: "0.6.0",
		subcommands: [Generate.self, Extension.self, Extension2.self, Json.self, GeneratePip.self]
	)
	
	@Option(transform: { s in
			Self.pythonlib = s
	}) var stdlib: Void?
	//@Option var pyextra: String?
	@Option(transform: { s in
		Self.extra = s
	}) var pyextra: Void?
	
	static func launchPython() throws {
//		let processInfo = ProcessInfo()
//		
//		let (stdlib, extra) = try {
//			//return ( PythonResources.python_stdlib, PythonResources.python_extra)
//			if let stdlib = App.pythonlib, let pyextra = App.extra {
//				return (stdlib, pyextra)
//			}
//			
//			else if let call = processInfo.arguments.first {
//				let callp = PathKit.Path(call)
//				if callp.isSymlink {
//					let real = try callp.symlinkDestination()
//					let root = real.parent()
//					return (
//						(root + "python-stdlib").string,
//						(root + "python-extra").string
//					)
//				}
//			}
//			return ("","")
//		}()
		let stdlib = "/Library/Frameworks/Python.framework/Versions/3.11/lib/python3.11"
		
		let python = PythonHandler.shared
		if !python.defaultRunning {
			python.start(stdlib: stdlib, app_packages: [], debug: true)
		}
	}
}

extension App {
	struct Generate: AsyncParsableCommand {
		static var configuration = CommandConfiguration(abstract: "Generates swiftonized file")
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var source: Path
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var destination: Path

		@Option(transform: { p -> PathKit.Path? in .init(p) }) var site: Path?
		
		func run() async throws {
			print(source)

			try App.launchPython()
			
			let wrappers = try SourceFilter(root: source)
			
			for file in wrappers.sources {
				
				switch file {
				case .pyi(let path):
					try await build_wrapper(src: path, dst: file.swiftFile(destination), site: site)
				case .py(let path):
					try await build_wrapper(src: path, dst: file.swiftFile(destination), site: site)
				case .both(_, let pyi):
					try await build_wrapper(src: pyi, dst: file.swiftFile(destination), site: site)
				}
			}
			
		}
	}
}

import ShadowPip
struct GeneratePip: AsyncParsableCommand {
	static var configuration = CommandConfiguration(abstract: "Generates swiftonized file")
	@Argument(transform: { p -> PathKit.Path in .init(p) }) var source: Path
	@Argument(transform: { p -> PathKit.Path in .init(p) }) var destination: Path
	
	@Option(transform: { p -> PathKit.Path? in .init(p) }) var site: Path?
	
	func run() async throws {
		print(source)
		
		try App.launchPython()
		
		let wrappers = try SourceFilter(root: source)
		
		for file in wrappers.sources {
			
			switch file {
			case .pyi(let path):
				try ShadowPip.test(file: path.url, dst: file.jsonFile(destination).url)
			case .py(let path):
				try ShadowPip.test(file: path.url, dst: file.jsonFile(destination).url)
			case .both(_, let pyi):
				try ShadowPip.test(file: pyi.url, dst: file.jsonFile(destination).url)
			}
		}
		
	}
}

extension App {
	struct Extension: AsyncParsableCommand {
		static var configuration = CommandConfiguration(abstract: "Generates swiftonized file")
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var source: Path
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var destination: Path
		
		@Option(transform: { p -> PathKit.Path? in .init(p) }) var site: Path?
		
		func run() async throws {
			print(source)
			
			try App.launchPython()
			
			let wrappers = try SourceFilter(root: source)
			
			for file in wrappers.sources {
				
				switch file {
				case .pyi(let path):
					try await build_wrapper_extension(src: path, dst: file.swiftFile(destination), site: site)
				case .py(let path):
					try await build_wrapper_extension(src: path, dst: file.swiftFile(destination), site: site)
				case .both(_, let pyi):
					try await build_wrapper_extension(src: pyi, dst: file.swiftFile(destination), site: site)
				}
			}
			
		}
	}
	
	struct Extension2: AsyncParsableCommand {
		static var configuration = CommandConfiguration(abstract: "Generates swiftonized file")
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var source: Path
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var destination: Path
		
		@Option(transform: { p -> PathKit.Path? in .init(p) }) var site: Path?
		
		func run() async throws {
			print(source)
			
			try App.launchPython()
			
			let wrappers = try SourceFilter(root: source)
			
			for file in wrappers.sources {
				
				switch file {
				case .pyi(let path):
					try await build_wrapper_extension2(src: path, dst: file.swiftFile(destination), site: site)
				case .py(let path):
					try await build_wrapper_extension2(src: path, dst: file.swiftFile(destination), site: site)
				case .both(_, let pyi):
					try await build_wrapper_extension2(src: pyi, dst: file.swiftFile(destination), site: site)
				}
			}
			
		}
	}
	
	struct Json: AsyncParsableCommand {
		static var configuration = CommandConfiguration(abstract: "Generates swiftonized file")
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var source: Path
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var destination: Path
		
		//@Option(transform: { p -> PathKit.Path? in .init(p) }) var site: Path?
		
		func run() async throws {
			
			
			//try App.launchPython()
			let json_files = source.filter(\.is_json)
			
			for file in json_files {
				let fname = file.lastComponentWithoutExtension
				
				try await build_wrapper(json: file, dst: destination + "\(fname).swift", site: nil)
			}
			
			
		}
	}
}

extension App {
	struct Macro: AsyncParsableCommand {
		
		static var configuration = CommandConfiguration(abstract: "Generates macros for swiftonized packages")
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var source: Path
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var destination: Path
		
		func run() async throws {
			
			try App.launchPython()
			
			let wrappers = try SourceFilter(root: source)
			
			for file in wrappers.sources {
				
				switch file {
				case .pyi(let path):
					break
				case .py(let path):
					break
				case .both(_, let pyi):
					break
				}
			}
			
		}
	}
}

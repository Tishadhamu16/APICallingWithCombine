//
//  Model.swift
//  APICallingWithCombine
//
//  Created by Tisha Dhamu on 17/02/25.
//
import SwiftUI

struct UserModel : Decodable, Hashable {
    var login : String
    var url : URL
}

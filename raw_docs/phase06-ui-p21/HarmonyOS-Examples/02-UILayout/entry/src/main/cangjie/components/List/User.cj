/**
 * Created on 2025/8/11
 */
package ohos_app_cangjie_entry.components.List
import std.random.Random
import std.collection.ArrayList


public class UserEntity {
    public let id: Int64
    public let name: String
    public let email: String
    public let phoneNumber: String
    public let country: String
    public let city: String

    public init(
        id: Int64,
        name: String,
        email: String,
        phoneNumber: String,
        country: String,
        city: String) {
        this.id = id
        this.name = name
        this.email = email
        this.phoneNumber = phoneNumber
        this.country = country
        this.city = city
    }
}

public let defaultUserEntities: Array<UserEntity> = [
    UserEntity(1, "Emma Carter", "emma.carter@example.com",	"+44 20 7946 0532",	"UK", "London"),
    UserEntity(2, "Daniel Martinez", "daniel.martinez@example.com", "+1 415 555 0193", "USA", "San Francisco"),
    UserEntity(3, "Sophia Bennett", "sophia.bennett@example.com", "+61 2 9374 2105", "Australia", "Sydney"),
    UserEntity(4, "Liam Thompson", "liam.thompson@example.com", "+64 9 379 1234", "NewZealand", "Auckland"),
    UserEntity(5, "Ava Robinson", "ava.robinson@example.com", "+33 1 45 67 89 01", "France", "Paris"),
    UserEntity(6, "Michael Foster", "michael.foster@example.com", "+49 30 12345678", "Germany", "Berlin"),
    UserEntity(7, "Isabella Brooks", "isabella.brooks@example.com", "+34 91 123 4567", "Spain", "Madrid"),
    UserEntity(8, "Noah Peterson", "noah.peterson@example.com", "+81 3 1234 5678", "Japan", "Tokyo"),
    UserEntity(9, "Charlotte Hughes", "charlotte.hughes@example.com", "+65 6123 4567", "Singapore", "Singapore"),
    UserEntity(10, "James Richardson", "james.richardson@example.com", "+971 4 123 4567", "UAE", "Dubai")
]

let random: Random = Random()

public func generateUserEntity() {
    var index: Int64 = random.nextInt64()
    if (index < 0) {
        index *= -1
    }
    index = index % defaultUserEntities.size
    defaultUserEntities[index];
}

public func generateUserEntities(num: Int64) {
    ArrayList<UserEntity>(num, { _ => generateUserEntity()});
}
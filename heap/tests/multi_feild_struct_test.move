/// This test module validates that the generic heap implementation correctly
/// supports multi-field structs while relying on comparators that operate on
/// a SINGLE selected field only.
///
/// The tests ensure:
/// 1. Comparator logic ignores unrelated fields
/// 2. The same dataset yields different ordering under different comparators

module heap::multi_field_tests {

    use heap::heap;
    use std::string::{Self, String};

   
    struct Person has store, drop, copy {
        id: u64,
        age: u8,
        salary: u128,
        score: u64,
        name: String,
    }

    struct Employee has store, drop, copy {
        employee_id: u64,
        department_id: u64,
        performance_score: u64,
        years_experience: u8,
        salary_grade: u8,
        bonus_points: u64,
    }


    /// Orders persons by descending age
    #[persistent]
    public fun cmp_person_by_age(a: Person, b: Person): bool {
        a.age > b.age
    }

    /// Orders persons by descending salary
    #[persistent]
    public fun cmp_person_by_salary(a: Person, b: Person): bool {
        a.salary > b.salary
    }

    /// Orders employees by descending performance score
    #[persistent]
    public fun cmp_employee_by_performance(a: Employee, b: Employee): bool {
        a.performance_score > b.performance_score
    }

    
    /// Verifies heap ordering depends ONLY on the selected field (age)
    #[test]
    public fun test_person_order_by_age_only() {
        let h = heap::new<Person>(cmp_person_by_age);

        heap::insert(&mut h, Person {
            id: 1,
            age: 25,
            salary: 100_000,
            score: 95,
            name: string::utf8(b"Alice"),
        });

        heap::insert(&mut h, Person {
            id: 2,
            age: 35,
            salary: 50_000,
            score: 70,
            name: string::utf8(b"Bob"),
        });

        heap::insert(&mut h, Person {
            id: 3,
            age: 30,
            salary: 150_000,
            score: 100,
            name: string::utf8(b"Charlie"),
        });

        assert!(heap::extract(&mut h).age == 35, 1);
        assert!(heap::extract(&mut h).age == 30, 2);
        assert!(heap::extract(&mut h).age == 25, 3);
    }

    /// Same dataset, different comparators → different ordering
    #[test]
    public fun test_same_data_different_comparators() {
        let p1 = Person {
            id: 1,
            age: 25,
            salary: 100_000,
            score: 95,
            name: string::utf8(b"Alice"),
        };

        let p2 = Person {
            id: 2,
            age: 35,
            salary: 50_000,
            score: 70,
            name: string::utf8(b"Bob"),
        };

        let p3 = Person {
            id: 3,
            age: 30,
            salary: 150_000,
            score: 100,
            name: string::utf8(b"Charlie"),
        };

        let h_age = heap::new<Person>(cmp_person_by_age);
        heap::insert(&mut h_age, p1);
        heap::insert(&mut h_age, p2);
        heap::insert(&mut h_age, p3);

        assert!(heap::extract(&mut h_age).age == 35, 1);

        let h_salary = heap::new<Person>(cmp_person_by_salary);
        heap::insert(&mut h_salary, p1);
        heap::insert(&mut h_salary, p2);
        heap::insert(&mut h_salary, p3);

        assert!(heap::extract(&mut h_salary).salary == 150_000, 2);
    }

    /// Generic correctness across different multi-field structs
    #[test]
    public fun test_employee_order_by_performance() {
        let h = heap::new<Employee>(cmp_employee_by_performance);

        heap::insert(&mut h, Employee {
            employee_id: 101,
            department_id: 1,
            performance_score: 80,
            years_experience: 5,
            salary_grade: 6,
            bonus_points: 1000,
        });

        heap::insert(&mut h, Employee {
            employee_id: 102,
            department_id: 2,
            performance_score: 95,
            years_experience: 3,
            salary_grade: 5,
            bonus_points: 500,
        });

        heap::insert(&mut h, Employee {
            employee_id: 103,
            department_id: 3,
            performance_score: 70,
            years_experience: 10,
            salary_grade: 8,
            bonus_points: 2000,
        });

        let top = heap::extract(&mut h);
        assert!(top.performance_score == 95, 1);
        assert!(top.employee_id == 102, 2);
    }
}

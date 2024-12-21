// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarn {
    // Structure to represent a course
    struct Course {
        uint256 id;
        string name;
        string description;
        uint256 reward;
        address creator;
        bool active;
    }

    // Structure to track user progress
    struct UserProgress {
        bool enrolled;
        bool completed;
    }

    uint256 public courseCounter;
    address public owner;
    mapping(uint256 => Course) public courses;
    mapping(uint256 => mapping(address => UserProgress)) public progress;

    event CourseCreated(uint256 indexed courseId, string name, uint256 reward);
    event UserEnrolled(uint256 indexed courseId, address indexed user);
    event CourseCompleted(uint256 indexed courseId, address indexed user, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to create a course
    function createCourse(string memory name, string memory description, uint256 reward) external onlyOwner {
        require(reward > 0, "Reward must be greater than zero");

        courseCounter++;
        courses[courseCounter] = Course({
            id: courseCounter,
            name: name,
            description: description,
            reward: reward,
            creator: msg.sender,
            active: true
        });

        emit CourseCreated(courseCounter, name, reward);
    }

    // Function to enroll in a course
    function enroll(uint256 courseId) external {
        require(courses[courseId].active, "Course is not active");
        require(!progress[courseId][msg.sender].enrolled, "Already enrolled");

        progress[courseId][msg.sender].enrolled = true;

        emit UserEnrolled(courseId, msg.sender);
    }

    // Function to mark course completion and claim reward
    function completeCourse(uint256 courseId) external {
        require(progress[courseId][msg.sender].enrolled, "Not enrolled in this course");
        require(!progress[courseId][msg.sender].completed, "Already completed");

        progress[courseId][msg.sender].completed = true;

        // Transfer reward to the user
        payable(msg.sender).transfer(courses[courseId].reward);

        emit CourseCompleted(courseId, msg.sender, courses[courseId].reward);
    }

    // Function to fund the contract
    function fundContract() external payable onlyOwner {}

    // Function to deactivate a course
    function deactivateCourse(uint256 courseId) external onlyOwner {
        require(courses[courseId].active, "Course is already inactive");
        courses[courseId].active = false;
    }
}

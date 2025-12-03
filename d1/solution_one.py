INITIAL_VAL = 50
CIRCLE_SIZE = 100
INPUT_PATH = 'input.txt'


def read_input(input_path=INPUT_PATH):
    with open(input_path, 'r') as file:
        data = [line.strip() for line in file.readlines()]
        int_data = [int(line[1:]) if line[0] == 'R' else -
                    int(line[1:]) for line in data]
    return int_data


def count_zeros(int_list, initial_value=INITIAL_VAL, circle_size=CIRCLE_SIZE):
    k = initial_value
    z = int(k == 0)

    for val in int_list:
        k = (k + val) % circle_size
        z += (k % circle_size == 0)
    return z


def main():
    input_data = read_input()
    print(count_zeros(input_data))


if __name__ == "__main__":
    main()

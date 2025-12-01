INITIAL_VAL = 50


def read_input():
    with open('input.txt', 'r') as file:
        data = [line.strip() for line in file.readlines()]
        int_data = [int(line[1:]) if line[0] == 'R' else -int(line[1:]) for line in data]
    return int_data


def count_zeros(int_list, initial_value=INITIAL_VAL):
    k = initial_value
    z = int(k == 0)

    for val in int_list:
        k = (k + val) % 100
        z += (k % 100 == 0)
    return z


def main():
    input_data = read_input()
    print(count_zeros(input_data))


if __name__ == "__main__":
    main()

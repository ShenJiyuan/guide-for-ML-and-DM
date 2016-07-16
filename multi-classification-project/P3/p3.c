#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <time.h>

#define CPU_THREAD_NUMBER 2

void split_file(char* filename, int n); //seperate the pos and neg sets respectively into n sets.
void filter(char* filename); //sperate the whole training set into two parts, the positive one and the negative one
void combine_p_n_sample(); //combine each separated positive subset with one separated negative subset

void* learning_thread(void* arg);
void* predicting_thread(void* arg);

void min();
void max();
void performance_calculate();
void clean(); // clean temp files, leaving the original training file, the original testing file, the result file and the performance file
const int thread_number = 24; // make sure that thread_number is even and that thread_number == positive_set_number * negative_set_number

const int positive_set_number = 3;
const int negative_set_number = 8;

const int predicting_sample_number = 37786;
const int training_sample_number = 113128;
const int positive_sample_number = 27876;	//for training
const int negative_sample_number = 85252;	//for training

float training_time, testing_time;
const char filename_result[20] = "result.txt";
int main()
{
	int i;
	filter("train.txt");
	split_file("positive.txt", positive_set_number);
	split_file("negative.txt", negative_set_number);
	combine_p_n_sample();
	clock_t training_start, training_end, testing_start, testing_end;
	pthread_t thread_id[thread_number];
	//*---------------------learning-----------------------*/
	training_start = clock();
	for (i = 0; i<thread_number; ++i)
		pthread_create(&thread_id[i], NULL, learning_thread, (void*)i);
	for (i = 0; i<thread_number; ++i)
		pthread_join(thread_id[i], NULL);
	training_end = clock();
	training_time = (float)(training_end - training_start) / CLOCKS_PER_SEC / (thread_number / CPU_THREAD_NUMBER);
	//*---------------------predicting-----------------------*/
	testing_start = clock();
	for (i = 0; i<thread_number; ++i)
		pthread_create(&thread_id[i], NULL, predicting_thread, (void*)i);
	for (i = 0; i<thread_number; ++i)
		pthread_join(thread_id[i], NULL);
	testing_end = clock();
	testing_time = (float)(testing_end - testing_start) / CLOCKS_PER_SEC / (thread_number / CPU_THREAD_NUMBER);
	//*---------------------Min and Max-----------------------*/
	min();
	max();
	performance_calculate();
	//clean();
	return 0;
}

void clean()
{
	int i;
	char filename[20];
	int total_number = positive_set_number * negative_set_number;
	remove("positive.txt");
	remove("negative.txt");
	for (i = 0; i<positive_set_number; ++i)
	{
		sprintf(filename, "pos%d.txt", i);
		remove(filename);
		sprintf(filename, "min%d.txt", i);
		remove(filename);
	}
	for (i = 0; i<negative_set_number; ++i)
	{
		sprintf(filename, "neg%d.txt", i);
		remove(filename);
	}
	for (i = 0; i<total_number; ++i)
	{
		sprintf(filename, "tra%d.txt", i);
		remove(filename);
		sprintf(filename, "out%d.txt", i);
		remove(filename);
		sprintf(filename, "tra%d.txt.model", i);
		remove(filename);
	}
}

void performance_calculate()
{
	const int length_of_temp_test = 100000;
	const int length_of_temp_result = 100000;
	char temp_test[length_of_temp_test], temp_result[length_of_temp_result], temp_performance[3];

	char filename_test[20] = "test.txt";
	char filename_performance[20] = "performance.txt";
	int TP = 0, TN = 0, FP = 0, FN = 0;
	float p, r, F1, TPR, FPR;
	int countdown = predicting_sample_number;
	FILE* fp_result, *fp_performance, *fp_test;
	fp_result = fopen(filename_result, "r");
	fp_test = fopen(filename_test, "r");
	fp_performance = fopen(filename_performance, "a");
	memset(temp_test, '\0', sizeof(temp_test));
	memset(temp_result, '\0', sizeof(temp_result));

	while (countdown-->0)
	{
		fgets(temp_test, length_of_temp_test, fp_test);
		fgets(temp_result, length_of_temp_result, fp_result);
		if (temp_test[0] == '1')
		if (temp_result[0] == '1')
			TP++;
		else
			FN++;
		else
		if (temp_result[0] != '1')
			TN++;
		else
			FP++;
	}
	p = TP*1.0 / (TP + FP);
	r = TP*1.0 / (TP + FN);
	F1 = 2.0*r*p / (r + p);
	TPR = TP*1.0 / (TP + FN);
	FPR = FP*1.0 / (FP + TN);
	fprintf(fp_performance, "precision = %f\nrecall = %f\nF1 = %f\nTPR = %f\nFPR = %f\ntraining time = %fs\ntesting time = %fs\n", p, r, F1, TPR, FPR, training_time, testing_time);

	fclose(fp_test);
	fclose(fp_result);
	fclose(fp_performance);
}

void max()
{
	int i, j;
	int countdown = predicting_sample_number;
	char filename_in[20];
	const int length_of_temp = 100000;
	char temp[length_of_temp];

	int count = 0; //count!=0 means 1, else means -1
	FILE* fp_result;
	FILE* fp_in[positive_set_number];
	memset(filename_in, '\0', sizeof(filename_in));
	fp_result = fopen(filename_result, "a");

	for (i = 0; i<positive_set_number; ++i)
	{
		sprintf(filename_in, "min%d.txt", i);
		fp_in[i] = fopen(filename_in, "r");
	}

	while (countdown-->0)
	{
		count = 0;
		for (j = 0; j<positive_set_number; ++j)
		{
			fgets(temp, length_of_temp, fp_in[j]);
			if (temp[0] == '1')
				count++;
		}
		if (count != 0)
			fputs("1\n", fp_result);
		else
			fputs("-1\n", fp_result);
	}
	for (i = 0; i<positive_set_number; ++i)
	{
		sprintf(filename_in, "min%d.txt", i);
		fclose(fp_in[i]);
	}
}

void min()
{
	int i, j;
	int countdown = predicting_sample_number;
	char filename_min[20], filename_in[20];
	const int length_of_temp = 100000;
	char temp[length_of_temp];

	int count = 0; //count==negative_set_number means 1, else means -1
	FILE* fp_min[positive_set_number];
	FILE* fp_in[positive_set_number*negative_set_number];
	memset(filename_min, '\0', sizeof(filename_min));
	memset(filename_in, '\0', sizeof(filename_in));
	memset(temp, '\0', sizeof(temp));
	for (i = 0; i<positive_set_number; ++i)
	{
		countdown = predicting_sample_number;
		sprintf(filename_min, "min%d.txt", i);
		fp_min[i] = fopen(filename_min, "a");
		for (j = 0; j<negative_set_number; ++j)
		{
			sprintf(filename_in, "out%d.txt", i*negative_set_number + j);
			fp_in[i*negative_set_number + j] = fopen(filename_in, "r");
		}
		while (countdown-->0)
		{
			count = 0;
			for (j = 0; j<negative_set_number; ++j)
			{
				fgets(temp, length_of_temp, fp_in[i*negative_set_number + j]);
				if (temp[0] == '1')
					count++;
			}
			if (count == negative_set_number)
				fputs("1\n", fp_min[i]);
			else
				fputs("-1\n", fp_min[i]);
		}

		for (j = 0; j<negative_set_number; ++j)
		{
			sprintf(filename_in, "out%d.txt", i*negative_set_number + j);
			fclose(fp_in[i*negative_set_number + j]);
		}
		fclose(fp_min[i]);
	}
}

void* learning_thread(void* arg)
{
	int i;
	i = (int)arg;
	char command[20];
	memset(command, '\0', sizeof(command));
	sprintf(command, "train tra%d.txt", i);
	system(command);
	return 0;
}

void* predicting_thread(void* arg)
{
	int i;
	i = (int)arg;
	char command[64];
	memset(command, '\0', sizeof(command));
	sprintf(command, "predict test.txt tra%d.txt.model out%d.txt", i, i);
	system(command);
	return 0;
}

void combine_p_n_sample()
{
	int i, j;
	FILE* fp_pos, *fp_neg, *fp_out;
	char filename_pos[10];
	char filename_neg[10];
	char filename_out[10];
	const int length_of_buffer = 100000;
	char temp[length_of_buffer];

	for (i = 0; i<positive_set_number; ++i)
	{
		sprintf(filename_pos, "pos%d.txt", i);
		for (j = 0; j<negative_set_number; ++j)
		{
			sprintf(filename_neg, "neg%d.txt", j);
			sprintf(filename_out, "tra%d.txt", negative_set_number*i + j);
			fp_pos = fopen(filename_pos, "r");
			fp_neg = fopen(filename_neg, "r");
			fp_out = fopen(filename_out, "a");
			while (fgets(temp, length_of_buffer, fp_pos) != NULL)
				fputs(temp, fp_out);
			while (fgets(temp, length_of_buffer, fp_neg) != NULL)
				fputs(temp, fp_out);
			fclose(fp_out);
			fclose(fp_pos);
			fclose(fp_neg);
		}
	}
}

void filter(char* filename)
{
	FILE* fp_in;
	FILE* fp_pos, *fp_neg;
	fp_in = fopen(filename, "r");
	fp_pos = fopen("positive.txt", "a");
	fp_neg = fopen("negative.txt", "a");
	const int length_of_buffer = 100000;
	char temp[length_of_buffer];
	memset(temp, '\0', sizeof(temp));

	int countdown = training_sample_number;
	while (countdown-->0)
	{
		fgets(temp, length_of_buffer, fp_in);
		if (temp[0] == '1')
			fputs(temp, fp_pos);
		else
			fputs(temp, fp_neg);
	}
	fclose(fp_in);
	fclose(fp_pos);
	fclose(fp_neg);
}

void split_file(char* filename, int n)
{
	FILE* fp_in;
	FILE* fp_out;
	int is_pos = 0;
	int count = 0, countdown = n, left_total, sample_number;
	char subset_filename[10];
	const int length_of_buffer = 100000;
	char temp[length_of_buffer];
	int size_of_subset;
	int order = 0; // current subset_file on the disk to write onto
	if (strcmp(filename, "positive.txt") == 0)
		is_pos = 1;

	sample_number = (is_pos == 1) ? positive_sample_number : negative_sample_number;
	size_of_subset = sample_number / n + 1;	// in sample numbers per subset
	left_total = (is_pos == 1) ? positive_sample_number : negative_sample_number;
	memset(temp, '\0', sizeof(temp));
	memset(subset_filename, '\0', sizeof(subset_filename));
	fp_in = fopen(filename, "r");

	while (countdown > 0)
	{
		count = 0;
		if (is_pos == 1)
			sprintf(subset_filename, "pos%d.txt", order);
		else
			sprintf(subset_filename, "neg%d.txt", order);
		fp_out = fopen(subset_filename, "a");
		while (count < size_of_subset && left_total > 0)
		{
			fgets(temp, length_of_buffer, fp_in);
			fputs(temp, fp_out);
			count++;
			left_total--;
		}
		countdown--;
		fclose(fp_out);
		order++;
	}
	fclose(fp_in);
}


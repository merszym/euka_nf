#! /usr/bin/env python3

from pysam import AlignmentFile
import sys

readfile = sys.argv[1]
writefile = sys.argv[2]
filterflag = int(sys.argv[3])
rm_dup_query_len = int(sys.argv[4])
num_min_dup = int(sys.argv[5])

samfile = AlignmentFile(readfile, "rb", check_sq = False)

#using template=samfile to copy the header
bamout = AlignmentFile(writefile, "wb", template=samfile)

duplicate = {}
length_passed = 0
passed = 0
allreads = 0

for aln in samfile.fetch(until_eof=True):
    allreads += 1
    # flag 5 is bit 1 and 4 (-F up)
    if((not (aln.flag & filterflag)) and (aln.query_length >= rm_dup_query_len)): #35
        length_passed += 1
        if aln.is_reverse: # if the read is reverse
            # the sequence has to be revcomp'ed'
            seq = aln.get_forward_sequence()
        else:
            seq = aln.query_sequence
        try: #if key doesn't exists, create in except below
            #duplicate[aln.query_alignment_sequence] += 1
            duplicate[seq] += 1
            #if(aln.query_sequence == "CGTGCGTACACGTGCGTACACGTGCGTACACGTGCG"):
            #    print(duplicate[aln.query_alignment_sequence],aln)
        except KeyError:
            duplicate[seq] = 1
            #duplicate[aln.query_alignment_sequence] = 1
            #if(aln.query_sequence == "CGTGCGTACACGTGCGTACACGTGCGTACACGTGCG"):
            #    print(aln)
        #keep only reads apearing at least twice
        #twice by defaul, now can be assigned through command line
        # we want the sequence to be printed only once it reaches the min
        #number of duplicates
        if(duplicate[seq] == num_min_dup):
            passed += 1
            bamout.write(aln)

samfile.close()
bamout.close() 

#write stats
dups_average = [v for v in duplicate.values() if (v>=num_min_dup)]
all_average = [v for v in duplicate.values()]
#avoid division by 0
if (len(all_average)):
    rounded_avrg_all = "{:.1f}".format(sum(all_average)/len(all_average))
else:
    rounded_avrg_all = "0"
if(len(dups_average)):
    rounded_avrg_final =" {:.1f}".format(sum(dups_average)/len(dups_average))
else:
    rounded_avrg_final = "0"

# print header
print(
    "#file",
    "all_seqs",
    f"seqs>={rm_dup_query_len}",
    f"avrg_times_seen_L>={rm_dup_query_len}",
    "final_noPCRdups_seqs",
    "avrg_times_seen_final",sep="\t",
    file=sys.stdout
)
#print out the stats
print(
    sys.argv[1],
    allreads, 
    length_passed, 
    rounded_avrg_all,
    passed, 
    rounded_avrg_final,
    sep="\t",
    file=sys.stdout
) 
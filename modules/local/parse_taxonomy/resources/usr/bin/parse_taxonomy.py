#! /usr/bin/env pypy3

import sys
import json

def get_names_dict(names_file):
    taxid_names_dict = {}
    name_taxid_dict = {}
    
    with open(names_file) as f:
        for line in f:
            if 'scientific name' in line:
                taxid,name,_ = line.strip().split("\t|\t", 2)
                taxid_names_dict[int(taxid)]=name
                name_taxid_dict[name]=int(taxid)
    return taxid_names_dict, name_taxid_dict

def get_nodes_dict(taxonomy_file):
    taxonomy_dict = {}
    
    # Read the taxonomy file and create a dictionary of taxonomic IDs and their parent and ranks
    with open(taxonomy_file) as f:
        for line in f:
            fields = line.strip().split('\t|\t')
            taxid = int(fields[0])
            parent = int(fields[1].strip())
            rank = fields[2].strip()

            # create or update entry
            if taxid in taxonomy_dict:
                taxonomy_dict[taxid].update({'rank':rank, 'parent':parent})
            else:
                taxonomy_dict[taxid] = {'rank': rank, 'parent': parent, 'children': []}
            
            # add the children link
            if parent in taxonomy_dict:
                taxonomy_dict[parent]['children'].append(taxid)
            else:
                taxonomy_dict[parent] = {'children':[taxid]}
    return taxonomy_dict

def traverse_tree(taxid, nodes):
    # this returns just a list of taxids, from the leaves to the root
    results = [taxid]
    try:
        record = nodes[taxid]
    except KeyError: 
        #this happens if the NCBI gbff dbxref[taxon] tag doesnt match the NCBI taxonomy (it happens!)
        # return an empty list and report the missing ID downstream
        return []
    if "parent" in record:
        if record["parent"] != taxid:
            results.extend( traverse_tree(record["parent"], nodes) )
    #for child in record['children']:
    #    if child != taxid:
    #        results.extend( traverse_tree(child, nodes) )
    return results
            

if __name__ == '__main__':
    nodefile = sys.argv[1]
    namesfile = sys.argv[2]
    taxa = sys.argv[3]
    
    names, names_taxid_dict = get_names_dict(namesfile)
    nodes = get_nodes_dict(nodefile)

    final_json = {}
    for taxon in taxa.split(','):
        taxid = names_taxid_dict[taxon]
        taxonomy = traverse_tree(taxid, nodes)
        
        # early return from traverse_tree due to NCBI error?
        if taxonomy == []:
            continue
        
        tmp = {nodes[x]['rank'] : names[x].replace(' ','_') for x in taxonomy}
        # {taxid:{ 'species':'Homo_sapiens', 'family':'Hominidae' }}
        if len(tmp)>0:
            final_json[taxon] = tmp
    json.dump(final_json, sys.stdout)
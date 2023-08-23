` parallel -lsf f .hostfile ./one_ended_models_base.pl `;
`mv parallel_*.log jobs/.`;
` parallel -lsf f .hostfile ./zero_ended_models_base.pl `;
`mv parallel_*.log jobs/.`;
` parallel -lsf f .hostfile ./xover1_models_base.pl `;
`mv parallel_*.log jobs/.`;
` parallel -lsf f .hostfile ./xover3_models_base.pl `;
`mv parallel_*.log jobs/.`;
` parallel -lsf f .hostfile ./corner_models_base.pl `;
`mv parallel_*.log jobs/.`;
` parallel -lsf f .hostfile ./two_ended_models_base.pl `;
`mv parallel_*.log jobs/.`;
` parallel -lsf f .hostfile ./two_ended_4lat_models_base.pl `;
`mv parallel_*.log jobs/.`;
` parallel -lsf f .hostfile ./two_ended_plate_models_base.pl `;
`mv parallel_*.log jobs/.`;
` parallel -lsf f .hostfile ./fill2D_models_base.pl `;
`mv parallel_*.log jobs/.`;

